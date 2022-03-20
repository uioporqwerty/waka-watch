import SwiftUI

@main
struct WakaWatchApp: App {
    init() {
        DependencyInjection.shared.register()
        _ = ConnectivityService.shared
        _ = DependencyInjection.shared.container.resolve(RollbarAPMService.self)
    }

    var body: some Scene {
        WindowGroup {
            DependencyInjection.shared.container.resolve(SplashView.self)!
        }
    }
}
