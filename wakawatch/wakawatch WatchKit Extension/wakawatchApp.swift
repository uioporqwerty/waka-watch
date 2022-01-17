import SwiftUI

@main
struct wakawatchApp: App {
    var body: some Scene {
        WindowGroup {
            let defaults = UserDefaults.standard
            ConnectView(authorized: defaults.bool(forKey: DefaultsKeys.authorized))
        }
    }
}
