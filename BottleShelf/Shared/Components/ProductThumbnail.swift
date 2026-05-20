import SwiftUI

struct ProductThumbnail: View {
    let category: ProductCategory
    var imageFileName: String?
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let uiImage = ImageStore.uiImage(fileName: imageFileName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(background)
                    .overlay {
                        Image(systemName: category.symbolName)
                            .font(.system(size: size * 0.36, weight: .semibold))
                            .foregroundStyle(iconColor)
                    }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var background: LinearGradient {
        switch category {
        case .sunscreen, .tool:
            LinearGradient(colors: [AppTheme.sage.opacity(0.28), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .perfume, .sample:
            LinearGradient(colors: [AppTheme.warning.opacity(0.24), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            LinearGradient(colors: [AppTheme.primarySoft, Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var iconColor: Color {
        switch category {
        case .sunscreen, .tool:
            AppTheme.sage
        case .perfume, .sample:
            AppTheme.warning
        case .baseMakeup, .lip, .eyeMakeup:
            AppTheme.primary
        default:
            AppTheme.ink.opacity(0.72)
        }
    }
}
