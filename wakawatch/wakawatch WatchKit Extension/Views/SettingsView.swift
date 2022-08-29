import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State var isActive = false

    init(viewModel: SettingsViewModel) {
        self.settingsViewModel = viewModel
    }

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                if self.settingsViewModel.showEnableNotificationsButton {
                    Button {
                        self.settingsViewModel
                            .telemetry
                            .recordViewEvent(elementName: "TAPPED: Enable Notifications button")
                        self.settingsViewModel.promptPermissions()
                    } label: {
                        Text(LocalizedStringKey("SettingsView_EnableNotifications_Button"))
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                }
                
                AsyncButton(action: {
                    self.settingsViewModel
                        .telemetry
                        .recordViewEvent(elementName: "TAPPED: Disconnect from WakaTime button")
                    try? await self.settingsViewModel.disconnect()
                }) {
                    Text(LocalizedStringKey("SettingsView_Disconnect_Button"))
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))

                NavigationLink(LocalizedStringKey("SettingsView_Licenses_Link"),
                               destination: LicensesView(viewModel:
                                                         DependencyInjection.shared
                                                                            .container
                                                                            .resolve(LicensesViewModel.self)!))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))

                Text(self.settingsViewModel.appVersion)
                    .font(Font.footnote)
                    .foregroundColor(.gray)
                    .padding()
                    .accessibilityLabel(Text(LocalizedStringKey("SettingsView_AppVersion_A11Y")
                                             .toString()
                                             .replaceArgs(self.settingsViewModel.appVersion)))
            }
        }
        .onAppear {
            self.settingsViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: SettingsView.self))")
        }
        .task {
            self.settingsViewModel.load()
        }
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SettingsView.self)!
    }
}
