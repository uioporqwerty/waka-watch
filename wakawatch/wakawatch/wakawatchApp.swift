import SwiftUI

@main
struct wakawatchApp: App {
    
    init() {
        #if !DEBUG
            let apmService = RollbarAPMService()
            apmService.configure()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
}
