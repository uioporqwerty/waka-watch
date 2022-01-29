import SwiftUI

struct ConnectView: View {
    @ObservedObject var connectivityService: ConnectivityService
    @AppStorage(DefaultsKeys.authorized) var storageAuthorized = false
    
    var body: some View {
        if !(connectivityService.authorized || storageAuthorized) {
            NavigationView {
                Text("Open the Waka Watch app on your primary device to connect to WakaTime.")
                    .navigationTitle(Text("Waka Watch"))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        else {
            NavigationView {
                TabView {
                    SummaryView()
                            .navigationTitle(Text("Summary"))
                            .navigationBarTitleDisplayMode(.inline)
                    LeaderboardView()
                            .navigationTitle(Text("Leaderboard"))
                            .navigationBarTitleDisplayMode(.inline)
                    ProfileView(user: nil)
                            .navigationTitle(Text("Profile"))
                            .navigationBarTitleDisplayMode(.inline)
                    SettingsView()
                            .navigationTitle(Text("Settings"))
                            .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView(connectivityService: ConnectivityService.shared)
    }
}
