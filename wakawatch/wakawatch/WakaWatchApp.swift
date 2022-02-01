import SwiftUI

@main
struct WakaWatchApp: App {
    init() {
        DependencyInjection.shared.register()
        let _ = ConnectivityService.shared
        
        guard let apmService = DependencyInjection.shared.container.resolve(APMService.self) else {
            return
        }
        apmService.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            DependencyInjection.shared.container.resolve(SplashView.self)!
        }
    }
}
