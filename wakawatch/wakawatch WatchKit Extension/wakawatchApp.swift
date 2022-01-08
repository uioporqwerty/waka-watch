import SwiftUI

@main
struct wakawatchApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                SummaryView(totalDisplayTime: "4 mins")
                LeaderboardView(leaderboardRecords: LeaderboardRecord.mockLeaderboard)
                ProfileView(user: User.mockUsers[0], rank: 1)
            }
        }
    }
}
