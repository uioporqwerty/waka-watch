import SwiftUI

@main
struct wakawatchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SummaryView(totalDisplayTime: "4 mins")
            }
        }
    }
}
