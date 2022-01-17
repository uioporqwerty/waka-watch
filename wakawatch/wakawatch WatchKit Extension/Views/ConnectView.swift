import SwiftUI
import WatchConnectivity

struct ConnectView: View {
    @ObservedObject var connectivityService: ConnectivityService
    
    private func isAuthorized() -> Bool {
        return $connectivityService.authorized.wrappedValue
    }
    
    var body: some View {
        if !connectivityService.authorized {
                VStack {
                    Text("Open the Waka Watch app on your primary device to connect to WakaTime.")
                }
            }
            else {
                TabView {
                    SummaryView(totalDisplayTime: "4 mins")
                    LeaderboardView(leaderboardRecords: LeaderboardRecord.mockLeaderboard)
                    ProfileView(user: User.mockUsers[0], rank: 1)
                }
            }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView(connectivityService: ConnectivityService.shared)
    }
}
