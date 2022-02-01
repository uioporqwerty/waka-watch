import SwiftUI

struct ConnectView: View {
    private var connectViewModel: ConnectViewModel
    @AppStorage(DefaultsKeys.authorized) var authorized = false
    
    init(viewModel: ConnectViewModel) {
        self.connectViewModel = viewModel
        self.connectViewModel.telemetry.recordViewEvent(elementName: String(describing: ConnectView.self))
    }
    
    var body: some View {
        if !authorized {
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
        DependencyInjection.shared.container.resolve(ConnectView.self)!
    }
}
