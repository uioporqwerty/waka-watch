import SwiftUI

@main
struct wakawatchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AuthorizationView()
            }
        }
    }
}
