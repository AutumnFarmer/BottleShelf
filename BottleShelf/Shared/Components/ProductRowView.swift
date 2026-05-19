import SwiftUI

struct ProductRowView: View {
    let product: BeautyProduct

    var body: some View {
        HStack(spacing: 12) {
            ProductThumbnail(category: product.category, imageFileName: product.imageFileName)

            VStack(alignment: .leading, spacing: 5) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                Text("\(product.displayBrand) · \(product.location.displayName)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
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
                return "过期"
            }
            if days <= ExpiryCalculator.expiringSoonDays {
                return "\(days) 天"
            }
        }
        return status.displayName
    }
}
