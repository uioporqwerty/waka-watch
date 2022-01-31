import SwiftUI

@main
struct WakaWatchApp: App {
    init() {
        //TODO: Move logic to composition root.
        #if !DEBUG
            let apmService = RollbarAPMService()
            apmService.configure()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ConnectView(connectivityService: ConnectivityService.shared).navigationTitle(Text("WakaWatch"))
        }
    }
}
