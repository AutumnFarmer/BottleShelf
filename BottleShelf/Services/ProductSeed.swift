import Foundation
import SwiftData

enum ProductSeed {
    @MainActor
    static func insertDemoProductsIfNeeded(in context: ModelContext, currentCount: Int) {
        guard currentCount == 0 else { return }

        let now = Date()
        let calendar = Calendar.current
        let demoProducts = [
            BeautyProduct(
                name: "维 C 亮肤精华",
                brand: "Glow Lab",
                category: .serum,
                location: .vanity,
                purchaseDate: calendar.date(byAdding: .month, value: -5, to: now),
                openedDate: calendar.date(byAdding: .day, value: -168, to: now),
                unopenedShelfLifeMonths: 24,
                openedShelfLifeMonths: 6,
                price: 328,
                note: "早上使用，质地清爽。"
            ),
            BeautyProduct(
                name: "清爽防晒乳",
                brand: "Sunbay",
                category: .sunscreen,
                location: .commuteBag,
                purchaseDate: calendar.date(byAdding: .month, value: -2, to: now),
                openedDate: calendar.date(byAdding: .day, value: -44, to: now),
                unopenedShelfLifeMonths: 24,
                openedShelfLifeMonths: 12,
                price: 189
            ),
            BeautyProduct(
                name: "玫瑰香水小样",
                brand: "Maison Rose",
                category: .sample,
                location: .travelBag,
                purchaseDate: calendar.date(byAdding: .month, value: -10, to: now),
                openedDate: calendar.date(byAdding: .month, value: -7, to: now),
                unopenedShelfLifeMonths: 24,
                openedShelfLifeMonths: 6,
                price: 38
            )
        ]

        demoProducts.forEach(context.insert)
    }
}
