import SwiftUI

@main
struct WakaWatchApp: App {
    init() {
        DependencyInjection.shared.register()
        let _ = ConnectivityService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            DependencyInjection.shared.container.resolve(SplashView.self)!
        }
    }
}
