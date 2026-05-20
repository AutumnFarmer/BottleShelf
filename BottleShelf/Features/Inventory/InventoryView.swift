import SwiftData
import SwiftUI

struct InventoryView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Query private var products: [BeautyProduct]
    @State private var showingEditor = false
    @State private var showingPaywall = false
    @State private var searchText = ""
    @State private var selectedCategory: ProductCategory?
    @State private var selectedStatus: ProductStatus?

    private var filteredProducts: [BeautyProduct] {
        products
            .filter { product in
                if let selectedCategory, product.category != selectedCategory {
                    return false
                }
                if let selectedStatus, ExpiryCalculator.status(for: product) != selectedStatus {
                    return false
                }
                guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return true
                }
                let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                return product.name.localizedCaseInsensitiveContains(keyword)
                    || product.brand.localizedCaseInsensitiveContains(keyword)
                    || product.location.displayName.localizedCaseInsensitiveContains(keyword)
            }
            .sorted { left, right in
                ExpiryCalculator.priorityScore(for: left) > ExpiryCalculator.priorityScore(for: right)
            }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filters

                if filteredProducts.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            title: "还没有符合条件的产品",
                            message: "可以调整筛选，或添加一件正在使用的护肤品。",
                            buttonTitle: "添加产品"
                        ) {
                            startAddFlow()
                        }
                        .padding(20)
                    }
                    .background(AppTheme.background)
                } else {
                    List {
                        ForEach(filteredProducts) { product in
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
                }
            }
            .navigationTitle("库存")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        startAddFlow()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("添加产品")
                }
            }
            .sheet(isPresented: $showingEditor) {
                ProductEditorView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.muted)
                TextField("搜索产品、品牌、位置", text: $searchText)
                    .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 14)
            .frame(height: 42)
            .background(Color.white)
            .clipShape(Capsule())

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("全部", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(ProductCategory.allCases) { category in
                        filterChip(category.displayName, isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("全部状态", isSelected: selectedStatus == nil) {
                        selectedStatus = nil
                    }
                    ForEach(ProductStatus.allCases) { status in
                        filterChip(status.displayName, isSelected: selectedStatus == status) {
                            selectedStatus = status
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(AppTheme.background)
    }

    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? Color.white : AppTheme.muted)
                .padding(.horizontal, 13)
                .frame(height: 34)
                .background(isSelected ? AppTheme.ink : Color.white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func startAddFlow() {
        if ProductLimit.canAddProduct(to: products, isPro: purchaseManager.isPro) {
            showingEditor = true
        } else {
            showingPaywall = true
        }
    }
}
