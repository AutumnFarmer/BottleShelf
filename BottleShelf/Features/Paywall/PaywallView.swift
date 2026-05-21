import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerCard
                    featureList
                    purchaseSummaryCard

                    if let message = purchaseManager.message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.muted)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(20)
                .padding(.bottom, 120)
            }
            .background(AppTheme.background)
            .navigationTitle("Pro")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                purchaseFooter
            }
            .task {
                await purchaseManager.start()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var canPurchase: Bool {
        purchaseManager.isPro
            || (purchaseManager.proProduct != nil
                && !purchaseManager.isLoadingProduct
                && !purchaseManager.isPurchasing)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(purchaseManager.isPro ? "Pro 已解锁" : "继续记录你的瓶瓶罐罐")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(purchaseManager.isPro ? "你已经可以记录无限产品，本地提醒和照片仍然只保存在这台设备上。" : "免费版最多记录 10 件。解锁后可以继续记录护肤品、彩妆、小样和香水。")
                .font(.subheadline)
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.primarySoft)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var featureList: some View {
        VStack(spacing: 10) {
            FeatureLine(icon: "infinity", title: "无限产品", message: "囤货、小样、旅行装都能记录。")
            FeatureLine(icon: "bell.badge", title: "本地到期提醒", message: "按到期前 30 天、7 天、当天和到期后 7 天提醒。")
            FeatureLine(icon: "lock.shield", title: "本地优先", message: "产品照片和记录默认不上传服务器。")
        }
    }

    private var purchaseSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("终身 Pro")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Spacer(minLength: 12)
                Text(priceText)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(priceColor)
                    .multilineTextAlignment(.trailing)
            }

            Text(priceCaption)
                .font(.footnote)
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            if shouldShowReloadButton {
                Button {
                    Task {
                        await purchaseManager.loadProducts()
                    }
                } label: {
                    Label("重新加载商品", systemImage: "arrow.clockwise")
                }
                .font(.footnote.weight(.medium))
                .buttonStyle(.bordered)
                .tint(AppTheme.primary)
                .disabled(purchaseManager.isLoadingProduct)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var purchaseFooter: some View {
        VStack(spacing: 10) {
            Button {
                if purchaseManager.isPro {
                    dismiss()
                } else {
                    Task {
                        await purchaseManager.purchasePro()
                    }
                }
            } label: {
                if purchaseManager.isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(primaryButtonTitle)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primary)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .disabled(!canPurchase)

            Button("恢复购买") {
                Task {
                    await purchaseManager.restorePurchases()
                }
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(AppTheme.muted)
            .disabled(purchaseManager.isPurchasing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
    }

    private var primaryButtonTitle: String {
        if purchaseManager.isPro {
            return "完成"
        }
        if purchaseManager.isLoadingProduct {
            return "正在读取价格"
        }
        if purchaseManager.proProduct == nil {
            return "商品暂不可用"
        }
        return "解锁 Pro"
    }

    private var priceText: String {
        if purchaseManager.isPro {
            return "已解锁"
        }
        if purchaseManager.isLoadingProduct {
            return "读取中"
        }
        return purchaseManager.displayPrice ?? "暂不可用"
    }

    private var priceCaption: String {
        if purchaseManager.isPro {
            return "恢复购买会重新同步你的 App Store 权益。"
        }
        if purchaseManager.proProduct != nil {
            return "价格来自 App Store，购买由 Apple 处理。"
        }
        return "暂时无法从 App Store 读取商品信息，请检查网络或稍后重试。"
    }

    private var priceColor: Color {
        purchaseManager.proProduct == nil && !purchaseManager.isPro ? AppTheme.muted : AppTheme.primary
    }

    private var shouldShowReloadButton: Bool {
        !purchaseManager.isPro
            && purchaseManager.proProduct == nil
            && !purchaseManager.isLoadingProduct
    }
}

private struct FeatureLine: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 28, height: 28)
                .background(AppTheme.primarySoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
