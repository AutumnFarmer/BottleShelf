import XCTest
@testable import BottleShelf

final class NotificationSchedulerTests: XCTestCase {
    func testReminderIdentifiersAreStableAndNamespaced() {
        let productID = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!

        let identifiers = NotificationScheduler.reminderIdentifiers(for: productID)

        XCTAssertEqual(identifiers.count, ReminderKind.allCases.count)
        XCTAssertEqual(
            identifiers,
            [
                "product.11111111-2222-3333-4444-555555555555.minus30",
                "product.11111111-2222-3333-4444-555555555555.minus7",
                "product.11111111-2222-3333-4444-555555555555.due",
                "product.11111111-2222-3333-4444-555555555555.after7"
            ]
        )
    }

    func testReminderCopyMentionsProductName() {
        XCTAssertTrue(ReminderKind.minus7.body(productName: "测试精华").contains("测试精华"))
        XCTAssertTrue(ReminderKind.due.body(productName: "测试面霜").contains("测试面霜"))
    }
}
