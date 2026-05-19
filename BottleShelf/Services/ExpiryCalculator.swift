import Foundation

enum ExpiryCalculator {
    static let expiringSoonDays = 30

    static func expiryDate(
        purchaseDate: Date?,
        unopenedShelfLifeMonths: Int?,
        openedDate: Date?,
        openedShelfLifeMonths: Int?,
        calendar: Calendar = .current
    ) -> Date? {
        let unopenedExpiry = dateByAddingMonths(unopenedShelfLifeMonths, to: purchaseDate, calendar: calendar)
        let openedExpiry = dateByAddingMonths(openedShelfLifeMonths, to: openedDate, calendar: calendar)

        switch (unopenedExpiry, openedExpiry) {
        case let (.some(unopened), .some(opened)):
            return min(unopened, opened)
        case let (.some(unopened), .none):
            return unopened
        case let (.none, .some(opened)):
            return opened
        case (.none, .none):
            return nil
        }
    }

    static func status(for product: BeautyProduct, now: Date = Date(), calendar: Calendar = .current) -> ProductStatus {
        if let override = product.statusOverride {
            return override
        }

        guard let expiryDate = product.expiryDate else {
            return product.openedDate == nil ? .unopened : .inUse
        }

        let today = calendar.startOfDay(for: now)
        let expiryDay = calendar.startOfDay(for: expiryDate)

        if expiryDay < today {
            return .expired
        }

        let days = calendar.dateComponents([.day], from: today, to: expiryDay).day ?? 0
        if days <= expiringSoonDays {
            return .expiringSoon
        }

        return product.openedDate == nil ? .unopened : .inUse
    }

    static func daysUntilExpiry(for product: BeautyProduct, now: Date = Date(), calendar: Calendar = .current) -> Int? {
        guard let expiryDate = product.expiryDate else { return nil }
        let today = calendar.startOfDay(for: now)
        let expiryDay = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: today, to: expiryDay).day
    }

    static func defaultOpenedShelfLifeMonths(for category: ProductCategory) -> Int {
        switch category {
        case .sunscreen: 12
        case .serum: 6
        case .cream: 12
        case .baseMakeup: 12
        case .eyeMakeup: 6
        case .lip: 24
        case .perfume: 36
        case .sample: 6
        case .cleanser, .toner, .mask, .tool, .other: 12
        }
    }

    static func priorityScore(for product: BeautyProduct, now: Date = Date()) -> Int {
        let status = status(for: product, now: now)
        switch status {
        case .expired:
            return 10_000
        case .expiringSoon:
            return 8_000 - abs(daysUntilExpiry(for: product, now: now) ?? 30)
        case .inUse:
            return 5_000 - abs(daysUntilExpiry(for: product, now: now) ?? 365)
        case .unopened:
            return 2_000 - abs(daysUntilExpiry(for: product, now: now) ?? 730)
        case .emptied, .discarded:
            return 0
        }
    }

    private static func dateByAddingMonths(_ months: Int?, to date: Date?, calendar: Calendar) -> Date? {
        guard let months, let date else { return nil }
        return calendar.date(byAdding: .month, value: months, to: date)
    }
}
