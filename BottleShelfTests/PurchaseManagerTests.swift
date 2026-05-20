import XCTest
@testable import BottleShelf

final class PurchaseManagerTests: XCTestCase {
    func testProProductIdentifierIsStable() {
        XCTAssertEqual(PurchaseManager.proProductID, "com.zmc.bottleshelf.pro.lifetime")
    }
}
