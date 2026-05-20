import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(purchaseManager.isPro ? "Pro 已解锁" : "继续记录你的瓶瓶罐罐")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(purchaseManager.isPro ? "你已经可以记录无限产品，本地提醒和照片仍然只保存在这台设备上。" : "免费版最多记录 10 件。解锁后可以继续记录护肤品、彩妆、小样和香水。")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(spacing: 10) {
                    FeatureLine(icon: "infinity", title: "无限产品", message: "囤货、小样、旅行装都能记录。")
                    FeatureLine(icon: "bell.badge", title: "本地到期提醒", message: "按到期前 30 天、7 天、当天和到期后 7 天提醒。")
                    FeatureLine(icon: "lock.shield", title: "本地优先", message: "产品照片和记录默认不上传服务器。")
                }

                Spacer()

                VStack(spacing: 12) {
                    HStack {
                        Text("终身 Pro")
                            .font(.headline)
                        Spacer()
                        Text(purchaseManager.displayPrice)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.primary)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

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
                            Text(purchaseManager.isPro ? "完成" : "解锁 Pro")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primary)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .disabled(purchaseManager.isPurchasing || purchaseManager.isLoadingProduct)

                    Button("恢复购买") {
                        Task {
                            await purchaseManager.restorePurchases()
                        }
                    }
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(AppTheme.muted)
                        .disabled(purchaseManager.isPurchasing)

                    if let message = purchaseManager.message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.muted)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(20)
            .background(AppTheme.background)
            .navigationTitle("Pro")
            .navigationBarTitleDisplayMode(.inline)
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
