import SwiftUI

struct ProductRowView: View {
    let product: BeautyProduct

    var body: some View {
        HStack(spacing: 12) {
            ProductThumbnail(category: product.category, imageFileName: product.imageFileName)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                Text(productSubtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
                    .lineLimit(1)

                Text(productMeta)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.muted.opacity(0.88))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            StatusTag(status: status, text: tagText)
        }
        .padding(10)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var status: ProductStatus {
        ExpiryCalculator.status(for: product)
    }

    private var tagText: String {
        if let days = ExpiryCalculator.daysUntilExpiry(for: product) {
            if days < 0 {
                return "超 \(abs(days)) 天"
            }
            if days == 0 {
                return "今天"
            }
            if days <= ExpiryCalculator.expiringSoonDays {
                return "剩 \(days) 天"
            }
        }
        return status.displayName
    }

    private var productSubtitle: String {
        if product.brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return product.category.displayName
        }
        return "\(product.displayBrand) · \(product.category.displayName)"
    }

    private var productMeta: String {
        "\(expirySummary) · \(product.location.displayName)"
    }

    private var expirySummary: String {
        guard let days = ExpiryCalculator.daysUntilExpiry(for: product) else {
            return "未设置建议期"
        }
        if days < 0 {
            return "已超过建议期 \(abs(days)) 天"
        }
        if days == 0 {
            return "今天到建议期"
        }
        return "还剩 \(days) 天"
    }
}
