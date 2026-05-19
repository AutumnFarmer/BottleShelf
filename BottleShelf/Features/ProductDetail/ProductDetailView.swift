import SwiftData
import SwiftUI

struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var product: BeautyProduct
    @State private var showingEditor = false
    @State private var confirmingDelete = false

    private var status: ProductStatus {
        ExpiryCalculator.status(for: product)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                dateGrid
                actionGrid
                noteSection
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("编辑") {
                    showingEditor = true
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            ProductEditorView(product: product)
        }
        .confirmationDialog("删除这件产品？", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                NotificationScheduler.cancelReminders(for: product.id)
                ImageStore.deleteImage(fileName: product.imageFileName)
                modelContext.delete(product)
                dismiss()
            }
            Button("取消", role: .cancel) {}
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                ProductThumbnail(category: product.category, imageFileName: product.imageFileName, size: 92)

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.ink)

                    Text("\(product.displayBrand) · \(product.category.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)

                    StatusTag(status: status, text: statusText)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var dateGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            InfoCard(title: "购买日期", value: product.purchaseDate?.shortDateText ?? "未填写")
            InfoCard(title: "开封日期", value: product.openedDate?.shortDateText ?? "未开封")
            InfoCard(title: "建议到期", value: product.expiryDate?.shortDateText ?? "未计算")
            InfoCard(title: "存放位置", value: product.location.displayName)
        }
    }

    private var actionGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button("标记开封") {
                    markOpened()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.primary)
                .disabled(product.openedDate != nil || status == .emptied || status == .discarded)

                Button("标记空瓶") {
                    markEmptied()
                }
                .buttonStyle(.bordered)
                .disabled(status == .emptied || status == .discarded)
            }

            HStack(spacing: 10) {
                Button("延后 7 天提醒") {
                    postponeExpiry()
                }
                .buttonStyle(.bordered)
                .disabled(product.expiryDate == nil || status == .emptied || status == .discarded)

                Button("删除", role: .destructive) {
                    confirmingDelete = true
                }
                .buttonStyle(.bordered)
            }
        }
        .controlSize(.large)
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("备注")
                .font(.headline)
                .foregroundStyle(AppTheme.ink)

            Text(product.note.isEmpty ? "还没有备注。" : product.note)
                .font(.subheadline)
                .foregroundStyle(product.note.isEmpty ? AppTheme.muted : AppTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var statusText: String {
        if let days = ExpiryCalculator.daysUntilExpiry(for: product) {
            if days < 0 {
                return "已过期 \(abs(days)) 天"
            }
            if days <= ExpiryCalculator.expiringSoonDays {
                return "还剩 \(days) 天"
            }
        }
        return status.displayName
    }

    private func markOpened() {
        product.openedDate = Date()
        product.isEstimatedOpenedDate = false
        product.statusOverride = nil
        if product.openedShelfLifeMonths == nil {
            product.openedShelfLifeMonths = ExpiryCalculator.defaultOpenedShelfLifeMonths(for: product.category)
        }
        product.refreshExpiryDate()
        scheduleReminderSync()
    }

    private func markEmptied() {
        product.statusOverride = .emptied
        product.emptiedAt = Date()
        product.updatedAt = Date()
        NotificationScheduler.cancelReminders(for: product.id)
    }

    private func postponeExpiry() {
        guard let expiryDate = product.expiryDate else { return }
        product.expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: expiryDate)
        product.updatedAt = Date()
        scheduleReminderSync()
    }

    private func scheduleReminderSync() {
        let snapshot = ProductReminderSnapshot(product: product)
        Task {
            await NotificationScheduler.syncRemindersIfAuthorized(for: snapshot)
        }
    }
}

private struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.muted)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
