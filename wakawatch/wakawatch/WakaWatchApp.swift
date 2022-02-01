import SwiftUI

@main
struct WakaWatchApp: App {
    init() {
        guard let apmService = DependencyInjection.shared.container.resolve(APMService.self) else {
            return
        }
        apmService.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
