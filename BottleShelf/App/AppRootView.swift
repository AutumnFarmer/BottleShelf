import SwiftUI

struct AppRootView: View {
#if DEBUG
    @State private var showingReviewPaywall = ProcessInfo.processInfo.arguments.contains("-showPaywallOnLaunch")
#endif

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("今天", systemImage: "calendar")
                }

            InventoryView()
                .tabItem {
                    Label("库存", systemImage: "shippingbox")
                }

            VanityView()
                .tabItem {
                    Label("梳妆台", systemImage: "square.grid.2x2")
                }

            SettingsView()
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }
        }
        .tint(AppTheme.primary)
#if DEBUG
        .sheet(isPresented: $showingReviewPaywall) {
            PaywallView()
        }
#endif
    }
}
