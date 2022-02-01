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
            ConnectView(connectivityService: ConnectivityService.shared).navigationTitle(Text("WakaWatch"))
        }
    }
}
