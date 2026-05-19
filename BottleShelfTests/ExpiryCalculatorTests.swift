import XCTest
@testable import BottleShelf

final class ExpiryCalculatorTests: XCTestCase {
    func testExpiryDateUsesEarlierOpenedDate() throws {
        let calendar = Calendar(identifier: .gregorian)
        let purchase = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let opened = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 3, day: 1)))

        let result = ExpiryCalculator.expiryDate(
            purchaseDate: purchase,
            unopenedShelfLifeMonths: 24,
            openedDate: opened,
            openedShelfLifeMonths: 6,
            calendar: calendar
        )

        let expected = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 9, day: 1)))
        XCTAssertEqual(result, expected)
    }

    func testStatusIsExpiringSoonWithinThirtyDays() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 1)))
        let opened = try XCTUnwrap(calendar.date(from: DateComponents(year: 2025, month: 11, day: 20)))
        let product = BeautyProduct(
            name: "测试精华",
            category: .serum,
            openedDate: opened,
            openedShelfLifeMonths: 6
        )

        XCTAssertEqual(ExpiryCalculator.status(for: product, now: now, calendar: calendar), .expiringSoon)
    }

    func testStatusIsExpiredAfterExpiryDate() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 2)))
        let opened = try XCTUnwrap(calendar.date(from: DateComponents(year: 2025, month: 11, day: 1)))
        let product = BeautyProduct(
            name: "测试防晒",
            category: .sunscreen,
            openedDate: opened,
            openedShelfLifeMonths: 6
        )

        XCTAssertEqual(ExpiryCalculator.status(for: product, now: now, calendar: calendar), .expired)
    }

    func testManualEmptiedStatusWins() {
        let product = BeautyProduct(name: "空瓶面霜", category: .cream)
        product.statusOverride = .emptied

        XCTAssertEqual(ExpiryCalculator.status(for: product), .emptied)
    }
}
