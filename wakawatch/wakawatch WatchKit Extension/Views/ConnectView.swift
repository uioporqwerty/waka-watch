import SwiftUI

struct ConnectView: View {
    @ObservedObject var connectivityService: ConnectivityService
    @AppStorage(DefaultsKeys.authorized) var storageAuthorized = false
    
    var body: some View {
        if !(connectivityService.authorized || storageAuthorized) {
            NavigationView {
                Text(LocalizedStringKey("ConnectView_Message"))
                    .navigationTitle(Text(LocalizedStringKey("ConnectView_Title")))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        else {
            NavigationView {
                TabView {
                    SummaryView()
                            .navigationTitle(Text(LocalizedStringKey("SummaryView_Title")))
                            .navigationBarTitleDisplayMode(.inline)
                    LeaderboardView()
                            .navigationTitle(Text(LocalizedStringKey("LeaderboardView_Title")))
                            .navigationBarTitleDisplayMode(.inline)
                    ProfileView(user: nil)
                            .navigationTitle(Text(LocalizedStringKey("ProfileView_Title")))
                            .navigationBarTitleDisplayMode(.inline)
                    SettingsView()
                            .navigationTitle(Text(LocalizedStringKey("SettingsView_Title")))
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
