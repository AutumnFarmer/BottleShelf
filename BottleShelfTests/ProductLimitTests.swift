import XCTest
@testable import BottleShelf

final class ProductLimitTests: XCTestCase {
    func testFreeUserCanAddBelowLimit() {
        let products = makeProducts(count: ProductLimit.freeLimit - 1)

        XCTAssertTrue(ProductLimit.canAddProduct(to: products))
    }

    func testFreeUserCannotAddAtLimit() {
        let products = makeProducts(count: ProductLimit.freeLimit)

        XCTAssertFalse(ProductLimit.canAddProduct(to: products))
    }

    func testProUserCanAddAtLimit() {
        let products = makeProducts(count: ProductLimit.freeLimit)

        XCTAssertTrue(ProductLimit.canAddProduct(to: products, isPro: true))
    }

    func testDiscardedProductsDoNotCountTowardFreeLimit() {
        var products = makeProducts(count: ProductLimit.freeLimit)
        products[0].statusOverride = .discarded

        XCTAssertTrue(ProductLimit.canAddProduct(to: products))
    }

    func testEmptiedProductsDoNotCountTowardFreeLimit() {
        var products = makeProducts(count: ProductLimit.freeLimit)
        products[0].statusOverride = .emptied

        XCTAssertTrue(ProductLimit.canAddProduct(to: products))
    }

    private func makeProducts(count: Int) -> [BeautyProduct] {
        (0..<count).map { index in
            BeautyProduct(name: "产品\(index)", category: .serum)
        }
    }
}
