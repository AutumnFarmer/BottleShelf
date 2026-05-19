import SwiftData
import SwiftUI

@main
struct BottleShelfApp: App {
    init() {
        ApplicationSupportDirectory.prepare()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: BeautyProduct.self)
    }
}
