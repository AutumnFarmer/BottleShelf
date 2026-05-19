import SwiftData
import SwiftUI

struct VanityView: View {
    @Query private var products: [BeautyProduct]

    private var locations: [(ProductLocation, [BeautyProduct])] {
        ProductLocation.allCases.map { location in
            (location, products.filter { $0.location == location })
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(locations, id: \.0.id) { location, products in
                        NavigationLink {
                            LocationProductListView(location: location, products: products)
                        } label: {
                            SceneCard(location: location, products: products)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(AppTheme.background)
            .navigationTitle("梳妆台")
        }
    }
}

private struct SceneCard: View {
    let location: ProductLocation
    let products: [BeautyProduct]

    private var expiringCount: Int {
        products.filter { product in
            let status = ExpiryCalculator.status(for: product)
            return status == .expiringSoon || status == .expired
        }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(location.displayName)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)

            Text("\(products.count) 件 · \(expiringCount) 件需留意")
                .font(.caption)
                .foregroundStyle(AppTheme.muted)

            HStack(spacing: -8) {
                ForEach(products.prefix(3)) { product in
                    ProductThumbnail(category: product.category, imageFileName: product.imageFileName, size: 30)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                if products.isEmpty {
                    Circle()
                        .fill(AppTheme.divider.opacity(0.5))
                        .frame(width: 30, height: 30)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
        .padding(14)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct LocationProductListView: View {
    let location: ProductLocation
    let products: [BeautyProduct]

    var body: some View {
        List {
            ForEach(products.sorted { ExpiryCalculator.priorityScore(for: $0) > ExpiryCalculator.priorityScore(for: $1) }) { product in
                NavigationLink {
                    ProductDetailView(product: product)
                } label: {
                    ProductRowView(product: product)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle(location.displayName)
    }
}
