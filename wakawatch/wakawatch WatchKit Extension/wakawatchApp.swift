import SwiftUI

@main
struct wakawatchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ProfileView(user: User.mockUsers[0])
            }
        }
    }
}
