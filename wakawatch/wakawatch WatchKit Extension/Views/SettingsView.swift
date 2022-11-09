import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State var isActive = false

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                if self.viewModel.showEnableNotificationsButton {
                    Button {
                        self.viewModel
                            .telemetry
                            .recordViewEvent(elementName: "TAPPED: Enable Notifications button")
                        self.viewModel
                            .analytics
                            .track(event: "Enable Notifications")
                        self.viewModel.promptPermissions()
                    } label: {
                        Text(LocalizedStringKey("SettingsView_EnableNotifications_Button"))
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                }
                
                NavigationLink(LocalizedStringKey("SettingsView_AddWatchFace_Link"),
                               destination: DependencyInjection.shared.container.resolve(AddWatchFaceView.self)!)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                
                Button {
                    self.viewModel
                        .telemetry
                        .recordViewEvent(elementName: "TAPPED: Toggle Mixpanel button")
                    self.viewModel
                        .analytics
                        .track(event: "Toggled Mixpanel")
                    
                    self.viewModel
                        .analyticsOptInOptOut()
                } label: {
                    Text(self.viewModel.analyticsOptInOptOutButtonLabel)
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                
                NavigationLink(LocalizedStringKey("SettingsView_Licenses_Link"),
                               destination: LicensesView(viewModel:
                                                         DependencyInjection.shared
                                                                            .container
                                                                            .resolve(LicensesViewModel.self)!))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                
                AsyncButton {
                    self.viewModel
                        .telemetry
                        .recordViewEvent(elementName: "TAPPED: Disconnect from WakaTime button")
                    try? await self.viewModel.disconnect()
                } label: {
                    Text(LocalizedStringKey("SettingsView_Disconnect_Button"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.displayP3, red: 171/255, green: 43/255, blue: 36/255, opacity: 1))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.borderless)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))

                Text(self.viewModel.appVersion)
                    .font(Font.footnote)
                    .foregroundColor(.gray)
                    .padding()
                    .accessibilityLabel(Text(LocalizedStringKey("SettingsView_AppVersion_A11Y")
                                             .toString()
                                             .replaceArgs(self.viewModel.appVersion)))
            }
        }
        .onAppear {
            self.viewModel
                .telemetry
                .recordViewEvent(elementName: "\(String(describing: SettingsView.self))")
            self.viewModel
                .analytics
                .track(event: "Settings View")
        }
        .task {
            self.viewModel.load()
        }
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SettingsView.self)!
    }
}
