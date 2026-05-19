enum ProductLimit {
    static let freeLimit = 10

    static func activeCount(in products: [BeautyProduct]) -> Int {
        products.filter { product in
            ExpiryCalculator.status(for: product) != .discarded
        }.count
    }

    static func canAddProduct(to products: [BeautyProduct], isPro: Bool = false) -> Bool {
        isPro || activeCount(in: products) < freeLimit
    }
}
