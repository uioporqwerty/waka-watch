import SwiftUI
import WatchConnectivity

struct ConnectView: View {
    @State var authorized: Bool
    
    var body: some View {
        Group {
            if !authorized {
                VStack {
                    Button("Connect to WakaTime", action: {
                        WKInterfaceController.open
                    })
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
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        let defaults = UserDefaults.standard
        ConnectView(authorized: defaults.bool(forKey: DefaultsKeys.authorized))
    }
}
