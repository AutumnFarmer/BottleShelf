import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("少浪费一瓶精华，就值回来了")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("解锁无限产品、高级提醒、空瓶统计和库存价值记录。")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(spacing: 10) {
                    FeatureLine(icon: "infinity", title: "无限产品", message: "囤货、小样、旅行装都能记录。")
                    FeatureLine(icon: "bell.badge", title: "高级提醒", message: "支持 7/15/30/60 天和自定义提醒。")
                    FeatureLine(icon: "chart.bar", title: "空瓶与浪费统计", message: "看清买了什么、用完什么、浪费多少。")
                }

                Spacer()

                VStack(spacing: 12) {
                    HStack {
                        Text("终身 Pro")
                            .font(.headline)
                        Spacer()
                        Text("¥28")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.primary)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button("解锁 Pro") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primary)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)

                    Button("恢复购买") {}
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(AppTheme.muted)
                }
            }
            .padding(20)
            .background(AppTheme.background)
            .navigationTitle("Pro")
            .navigationBarTitleDisplayMode(.inline)
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
