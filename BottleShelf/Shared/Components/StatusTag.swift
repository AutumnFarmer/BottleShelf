import SwiftUI

struct StatusTag: View {
    let status: ProductStatus
    var text: String?

    var body: some View {
        Text(text ?? status.displayName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.tint)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 9)
            .frame(minHeight: 26)
            .background(status.background)
            .clipShape(Capsule())
    }
}
