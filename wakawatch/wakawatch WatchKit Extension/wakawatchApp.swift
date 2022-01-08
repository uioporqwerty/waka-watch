import SwiftUI

@main
struct wakawatchApp: App {
    var body: some Scene {
        WindowGroup {
            let defaults = UserDefaults.standard
            AuthorizationView(authorized: defaults.bool(forKey: DefaultsKeys.authorized))
        }
    }
}
