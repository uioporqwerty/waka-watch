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
                    DependencyInjection.shared.container.resolve(SummaryView.self)!
                            .navigationTitle(Text(LocalizedStringKey("SummaryView_Title")))
                            .navigationBarTitleDisplayMode(.inline)
                    DependencyInjection.shared.container.resolve(LeaderboardView.self)!
                            .navigationTitle(Text(LocalizedStringKey("LeaderboardView_Title")))
                            .navigationBarTitleDisplayMode(.inline)
                    DependencyInjection.shared.container.resolve(ProfileView.self)!
                            .navigationTitle(Text(LocalizedStringKey("ProfileView_Title")))
                            .navigationBarTitleDisplayMode(.inline)
                    DependencyInjection.shared.container.resolve(SettingsView.self)!
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
