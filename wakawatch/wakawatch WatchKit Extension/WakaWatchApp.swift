import SwiftUI

@main
struct WakaWatchApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate

    init() {
        DependencyInjection.shared.register()
        _ = ConnectivityService.shared
        _ = DependencyInjection.shared.container.resolve(RollbarAPMService.self)
    }

    var body: some Scene {
        WindowGroup {
            DependencyInjection.shared.container.resolve(ConnectView.self)!
                                                .navigationTitle(Text("WakaWatch"))
        }
    }
}
