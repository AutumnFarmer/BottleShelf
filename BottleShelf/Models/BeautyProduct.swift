import Foundation
import SwiftData

@Model
final class BeautyProduct {
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String
    var categoryRaw: String
    var locationRaw: String
    var statusOverrideRaw: String?
    var purchaseDate: Date?
    var openedDate: Date?
    var unopenedShelfLifeMonths: Int?
    var openedShelfLifeMonths: Int?
    var expiryDate: Date?
    var price: Double?
    var imageFileName: String?
    var note: String
    var isEstimatedOpenedDate: Bool
    var createdAt: Date
    var updatedAt: Date
    var emptiedAt: Date?
    var discardedAt: Date?

    init(
        id: UUID = UUID(),
        name: String,
        brand: String = "",
        category: ProductCategory,
        location: ProductLocation = .vanity,
        purchaseDate: Date? = nil,
        openedDate: Date? = nil,
        unopenedShelfLifeMonths: Int? = nil,
        openedShelfLifeMonths: Int? = nil,
        price: Double? = nil,
        note: String = "",
        isEstimatedOpenedDate: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.categoryRaw = category.rawValue
        self.locationRaw = location.rawValue
        self.statusOverrideRaw = nil
        self.purchaseDate = purchaseDate
        self.openedDate = openedDate
        self.unopenedShelfLifeMonths = unopenedShelfLifeMonths
        self.openedShelfLifeMonths = openedShelfLifeMonths
        self.expiryDate = ExpiryCalculator.expiryDate(
            purchaseDate: purchaseDate,
            unopenedShelfLifeMonths: unopenedShelfLifeMonths,
            openedDate: openedDate,
            openedShelfLifeMonths: openedShelfLifeMonths
        )
        self.price = price
        self.imageFileName = nil
        self.note = note
        self.isEstimatedOpenedDate = isEstimatedOpenedDate
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.emptiedAt = nil
        self.discardedAt = nil
    }
}

extension BeautyProduct {
    var category: ProductCategory {
        get { ProductCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var location: ProductLocation {
        get { ProductLocation(rawValue: locationRaw) ?? .other }
        set { locationRaw = newValue.rawValue }
    }

    var statusOverride: ProductStatus? {
        get {
            guard let statusOverrideRaw else { return nil }
            return ProductStatus(rawValue: statusOverrideRaw)
        }
        set {
            statusOverrideRaw = newValue?.rawValue
        }
    }

    var displayBrand: String {
        brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "未填写品牌" : brand
    }

    func refreshExpiryDate() {
        expiryDate = ExpiryCalculator.expiryDate(
            purchaseDate: purchaseDate,
            unopenedShelfLifeMonths: unopenedShelfLifeMonths,
            openedDate: openedDate,
            openedShelfLifeMonths: openedShelfLifeMonths
        )
        updatedAt = Date()
    }
}
