import SwiftUI

@main
struct WakaWatchApp: App {
    init() {
        #if !DEBUG
            let apmService = RollbarAPMService()
            apmService.configure()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
