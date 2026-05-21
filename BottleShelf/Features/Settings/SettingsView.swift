import SwiftData
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Query private var products: [BeautyProduct]
    @State private var showingPaywall = false

    private var activeCount: Int {
        ProductLimit.activeCount(in: products)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("瓶瓶罐罐")
                            .font(.title3.weight(.bold))
                        Text("化妆品保质期与库存提醒")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                        Text(membershipSummary)
                            .font(.caption)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .padding(.vertical, 8)
                }

                Section("会员") {
                    Button {
                        showingPaywall = true
                    } label: {
                        Label(purchaseManager.isPro ? "查看 Pro" : "解锁 Pro", systemImage: "sparkles")
                    }
                    Button {
                        Task {
                            await purchaseManager.restorePurchases()
                        }
                    } label: {
                        Label("恢复购买", systemImage: "arrow.clockwise")
                    }
                    .disabled(purchaseManager.isPurchasing)
                }

                Section("设置") {
                    NavigationLink {
                        ReminderSettingsPlaceholderView()
                    } label: {
                        Label("提醒设置", systemImage: "bell")
                    }
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        Label("隐私与数据", systemImage: "lock.shield")
                    }
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("关于 App", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("我的")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private var membershipSummary: String {
        if purchaseManager.isPro {
            return "Pro 已解锁，可记录无限产品"
        }
        return "当前已记录 \(activeCount) / \(ProductLimit.freeLimit) 件免费额度"
    }
}

private struct ReminderSettingsPlaceholderView: View {
    var body: some View {
        List {
            Section {
                Label("到期前 30 天提醒", systemImage: "checkmark.circle")
                Label("到期前 7 天提醒", systemImage: "checkmark.circle")
                Label("到期当天提醒", systemImage: "checkmark.circle")
                Label("到期后 7 天处理提醒", systemImage: "checkmark.circle")
            } footer: {
                Text("在今天页开启提醒后，系统会为有建议到期日的产品安排本地通知。")
            }
        }
        .navigationTitle("提醒设置")
    }
}

private struct PrivacyView: View {
    var body: some View {
        List {
            Section("本地优先") {
                Text("MVP 默认不注册、不上传服务器。产品名称、日期、价格、备注等信息保存在本机。")
                Text("后续如果加入 iCloud、OCR 或 AI，会在这里明确说明数据流向并提供关闭入口。")
            }

            Section("使用边界") {
                Text("到期日期仅根据你填写的信息估算，用于库存管理和日期提醒，不构成安全、医疗或功效判断。")
            }
        }
        .navigationTitle("隐私与数据")
    }
}

private struct AboutView: View {
    var body: some View {
        List {
            Section {
                Text("瓶瓶罐罐")
                Text("版本 1.0")
                Text("一个帮你管理护肤品、彩妆、小样和香水保质期的私人梳妆台工具。")
            }
        }
        .navigationTitle("关于")
    }
}
