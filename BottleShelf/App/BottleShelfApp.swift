import SwiftData
import SwiftUI

@main
struct BottleShelfApp: App {
    @StateObject private var purchaseManager = PurchaseManager()

    init() {
        ApplicationSupportDirectory.prepare()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(purchaseManager)
                .task {
                    await purchaseManager.start()
                }
        }
        .modelContainer(for: BeautyProduct.self)
    }
}
