import SwiftUI

struct ConnectView: View {
    @ObservedObject var connectivityService: ConnectivityService
    @State var authorized = false
    
    func isAuthorized() -> Bool {
        let defaults = UserDefaults.standard
        let isStoredAuthorized = defaults.bool(forKey: DefaultsKeys.authorized)
        return ConnectivityService.shared.authorized || isStoredAuthorized
    }
    
    var body: some View {
        if !isAuthorized() {
            VStack {
                Text("Open the Waka Watch app on your primary device to connect to WakaTime.")
            }
        }
        else {
            TabView {
                SummaryView()
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
