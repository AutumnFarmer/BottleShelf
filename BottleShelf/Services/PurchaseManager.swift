import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    nonisolated static let proProductID = "com.zmc.bottleshelf.pro.lifetime"

    @Published private(set) var proProduct: Product?
    @Published private(set) var isPro = false
    @Published private(set) var isLoadingProduct = false
    @Published private(set) var isPurchasing = false
    @Published var message: String?

    var displayPrice: String {
        proProduct?.displayPrice ?? "¥28"
    }

    private var updatesTask: Task<Void, Never>?

    func start() async {
        if updatesTask == nil {
            updatesTask = observeTransactionUpdates()
        }

        await refreshEntitlements()
        await loadProducts()
    }

    func loadProducts() async {
        isLoadingProduct = true
        defer { isLoadingProduct = false }

        do {
            let products = try await Product.products(for: [Self.proProductID])
            proProduct = products.first
            if proProduct == nil {
                message = "暂时无法加载 Pro 商品，请稍后再试。"
            }
        } catch {
            message = "暂时无法加载 Pro 商品，请检查网络或稍后再试。"
        }
    }

    func purchasePro() async {
        if proProduct == nil {
            await loadProducts()
        }

        guard let proProduct else {
            message = "Pro 商品还没准备好，请稍后再试。"
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await proProduct.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                await refreshEntitlements()
                message = isPro ? "Pro 已解锁。" : "购买已完成，正在同步权益。"
            case .userCancelled:
                message = nil
            case .pending:
                message = "购买正在等待确认。"
            @unknown default:
                message = "购买状态暂时无法确认，请稍后查看。"
            }
        } catch {
            message = "购买失败，请稍后再试。"
        }
    }

    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            message = isPro ? "已恢复 Pro 权益。" : "没有找到可恢复的 Pro 购买。"
        } catch {
            message = "恢复购买失败，请稍后再试。"
        }
    }

    func refreshEntitlements() async {
        var hasPro = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? verified(result) else {
                continue
            }

            if transaction.productID == Self.proProductID,
               transaction.revocationDate == nil {
                hasPro = true
            }
        }

        isPro = hasPro
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }

                do {
                    let transaction = try self.verified(result)
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    await MainActor.run {
                        self.message = "购买状态同步失败，请稍后重试。"
                    }
                }
            }
        }
    }

    private nonisolated func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw PurchaseError.unverifiedTransaction
        }
    }
}

private enum PurchaseError: Error {
    case unverifiedTransaction
}
