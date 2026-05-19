import Foundation
import UserNotifications

struct ProductReminderSnapshot: Sendable {
    let id: UUID
    let name: String
    let expiryDate: Date?

    init(id: UUID, name: String, expiryDate: Date?) {
        self.id = id
        self.name = name
        self.expiryDate = expiryDate
    }

    init(product: BeautyProduct) {
        self.id = product.id
        self.name = product.name
        self.expiryDate = product.expiryDate
    }
}

enum ReminderKind: String, CaseIterable {
    case minus30
    case minus7
    case due
    case after7

    var offsetDays: Int {
        switch self {
        case .minus30: -30
        case .minus7: -7
        case .due: 0
        case .after7: 7
        }
    }

    var title: String {
        switch self {
        case .minus30: "建议优先使用"
        case .minus7: "即将到期"
        case .due: "今天到期"
        case .after7: "建议处理"
        }
    }

    func body(productName: String) -> String {
        switch self {
        case .minus30:
            return "\(productName) 距离建议到期还有 30 天。"
        case .minus7:
            return "\(productName) 距离建议到期还有 7 天。"
        case .due:
            return "\(productName) 已到你记录的建议到期日。"
        case .after7:
            return "\(productName) 已超过建议使用期 7 天，可以标记空瓶或处理。"
        }
    }
}

enum NotificationScheduler {
    static func reminderIdentifiers(for productID: UUID) -> [String] {
        ReminderKind.allCases.map { reminderIdentifier(productID: productID, kind: $0) }
    }

    static func shouldOfferAuthorization() async -> Bool {
        await authorizationStatus() == .notDetermined
    }

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func syncRemindersIfAuthorized(for snapshot: ProductReminderSnapshot) async {
        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional || status == .ephemeral else {
            return
        }
        await syncReminders(for: snapshot)
    }

    static func syncReminders(for snapshot: ProductReminderSnapshot) async {
        cancelReminders(for: snapshot.id)

        guard let expiryDate = snapshot.expiryDate else { return }

        for kind in ReminderKind.allCases {
            guard let reminderDate = Calendar.current.date(byAdding: .day, value: kind.offsetDays, to: expiryDate),
                  reminderDate > Date() else {
                continue
            }
            let request = notificationRequest(for: snapshot, kind: kind, reminderDate: reminderDate)
            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    static func syncAllReminders(for snapshots: [ProductReminderSnapshot]) async {
        for snapshot in snapshots {
            await syncReminders(for: snapshot)
        }
    }

    static func cancelReminders(for productID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: reminderIdentifiers(for: productID))
    }

    private static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    private static func notificationRequest(
        for snapshot: ProductReminderSnapshot,
        kind: ReminderKind,
        reminderDate: Date
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = kind.title
        content.body = kind.body(productName: snapshot.name)
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(
            identifier: reminderIdentifier(productID: snapshot.id, kind: kind),
            content: content,
            trigger: trigger
        )
    }

    private static func reminderIdentifier(productID: UUID, kind: ReminderKind) -> String {
        "product.\(productID.uuidString).\(kind.rawValue)"
    }
}
