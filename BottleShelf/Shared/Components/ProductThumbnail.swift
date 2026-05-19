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
                        VStack(spacing: 0) {
                            Capsule()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: size * 0.18, height: size * 0.12)
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color.white.opacity(0.68))
                                .frame(width: size * 0.32, height: size * 0.48)
                        }
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
}
