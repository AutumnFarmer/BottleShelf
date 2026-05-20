import SwiftData
import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Query private var products: [BeautyProduct]
    @State private var showingEditor = false
    @State private var showingPaywall = false
    @State private var shouldOfferReminderPermission = false
    @State private var showingReminderExplanation = false

    private var activeProducts: [BeautyProduct] {
        products.filter { product in
            let status = ExpiryCalculator.status(for: product)
            return status != .emptied && status != .discarded
        }
    }

    private var priorityProducts: [BeautyProduct] {
        activeProducts
            .sorted { left, right in
                ExpiryCalculator.priorityScore(for: left) > ExpiryCalculator.priorityScore(for: right)
            }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    heroCard
                    reminderPermissionCard
                    summaryGrid
                    prioritySection
                }
                .padding(20)
            }
            .background(AppTheme.background)
            .navigationTitle("今天")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        startAddFlow()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("添加产品")
                }
            }
            .sheet(isPresented: $showingEditor) {
                ProductEditorView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .alert("开启到期提醒？", isPresented: $showingReminderExplanation) {
                Button("稍后", role: .cancel) {}
                Button("开启提醒") {
                    requestReminderPermission()
                }
            } message: {
                Text("开启后，App 会根据你填写的日期，在到期前 30 天、7 天和当天提醒你。")
            }
            .onAppear {
                Task {
                    await refreshReminderOffer()
                }
            }
            .onChange(of: products.count) {
                Task {
                    await refreshReminderOffer()
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(heroTitle)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.ink)

            Text(heroMessage)
                .font(.subheadline)
                .foregroundStyle(AppTheme.muted)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.white, AppTheme.primarySoft],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            SummaryStatCard(value: "\(activeProducts.count)", label: "库存")
            SummaryStatCard(value: "\(count(for: .expiringSoon))", label: "临期")
            SummaryStatCard(value: "\(count(for: .expired))", label: "过期")
            SummaryStatCard(value: "\(count(for: .emptied))", label: "空瓶")
        }
    }

    @ViewBuilder
    private var reminderPermissionCard: some View {
        if shouldOfferReminderPermission {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "bell.badge")
                    .foregroundStyle(AppTheme.primary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("开启到期提醒")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                    Text("保存产品后，系统会按建议到期日安排本地通知。")
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                }

                Spacer(minLength: 8)

                Button("开启") {
                    showingReminderExplanation = true
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.primary)
            }
            .padding(14)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日优先使用")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Spacer()
            }

            if priorityProducts.isEmpty {
                EmptyStateView(
                    title: "先添加 3 件正在用的产品",
                    message: "添加后这里会自动展示快过期和需要优先使用的产品。",
                    buttonTitle: "添加第一件"
                ) {
                    startAddFlow()
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(priorityProducts) { product in
                        NavigationLink {
                            ProductDetailView(product: product)
                        } label: {
                            ProductRowView(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var heroTitle: String {
        guard let first = priorityProducts.first else {
            return "把瓶瓶罐罐管起来"
        }
        switch ExpiryCalculator.status(for: first) {
        case .expired:
            return "\(first.name) 已超过建议使用期"
        case .expiringSoon:
            return "先用这件：\(first.name)"
        default:
            return "今天状态稳定"
        }
    }

    private var heroMessage: String {
        guard let first = priorityProducts.first else {
            return "记录开封时间、到期日期和存放位置，减少重复购买和过期浪费。"
        }
        if let days = ExpiryCalculator.daysUntilExpiry(for: first) {
            if days < 0 {
                return "根据你填写的日期，它已超过建议使用期 \(abs(days)) 天。"
            }
            return "根据你填写的日期，距离建议到期还有 \(days) 天。"
        }
        return "还没有设置到期日期，可以进入详情补充。"
    }

    private func count(for status: ProductStatus) -> Int {
        products.filter { ExpiryCalculator.status(for: $0) == status }.count
    }

    private var reminderSnapshots: [ProductReminderSnapshot] {
        activeProducts.map(ProductReminderSnapshot.init(product:))
    }

    private var hasSchedulableProducts: Bool {
        activeProducts.contains { $0.expiryDate != nil }
    }

    private func startAddFlow() {
        if ProductLimit.canAddProduct(to: products, isPro: purchaseManager.isPro) {
            showingEditor = true
        } else {
            showingPaywall = true
        }
    }

    private func requestReminderPermission() {
        let snapshots = reminderSnapshots
        Task {
            let allowed = await NotificationScheduler.requestAuthorization()
            if allowed {
                await NotificationScheduler.syncAllReminders(for: snapshots)
            }
            await refreshReminderOffer()
        }
    }

    @MainActor
    private func refreshReminderOffer() async {
        guard hasSchedulableProducts else {
            shouldOfferReminderPermission = false
            return
        }

        shouldOfferReminderPermission = await NotificationScheduler.shouldOfferAuthorization()
    }
}
