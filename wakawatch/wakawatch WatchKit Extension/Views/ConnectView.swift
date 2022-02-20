import SwiftUI

struct ConnectView: View {
    private var connectViewModel: ConnectViewModel
    @AppStorage(DefaultsKeys.authorized) var authorized = false
    @State var requiresUpdate = false

    init(viewModel: ConnectViewModel) {
        self.connectViewModel = viewModel
    }

    var body: some View {
        VStack {
            if self.requiresUpdate {
                Text(LocalizedStringKey("ConnectView_UpdateRequired_Message"))
            } else if !authorized {
                NavigationView {
                    Text(LocalizedStringKey("ConnectView_Message"))
                        .navigationTitle(Text(LocalizedStringKey("ConnectView_Title")))
                        .navigationBarTitleDisplayMode(.inline)
                }
            } else {
                TabView {
                    // TODO: Remove once apple fixes NavigationLink bug on 8.4+
                    NavigationView {
                        DependencyInjection.shared.container.resolve(SummaryView.self)!
                                .navigationTitle(Text(LocalizedStringKey("SummaryView_Title")))
                                .navigationBarTitleDisplayMode(.inline)
                    }
                    NavigationView {
                        DependencyInjection.shared.container.resolve(LeaderboardView.self)!
                                .navigationTitle(Text(LocalizedStringKey("LeaderboardView_Title")))
                                .navigationBarTitleDisplayMode(.inline)
                    }
                    NavigationView {
                        DependencyInjection.shared.container.resolve(ProfileView.self)!
                                .navigationTitle(Text(LocalizedStringKey("ProfileView_Title")))
                                .navigationBarTitleDisplayMode(.inline)
                    }
                    NavigationView {
                        DependencyInjection.shared.container.resolve(SettingsView.self)!
                                .navigationTitle(Text(LocalizedStringKey("SettingsView_Title")))
                                .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
        .onAppear {
            self.connectViewModel.telemetry.recordViewEvent(elementName: String(describing: ConnectView.self))
        }
        .task {
            self.requiresUpdate = await self.connectViewModel.requiresUpdate()
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(ConnectView.self)!
    }
}
