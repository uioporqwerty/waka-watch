import SwiftUI

@main
struct wakawatchApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                SummaryView(totalDisplayTime: "4 mins")
                ProfileView(user: User.mockUsers[0])
            }
        }
    }
}
