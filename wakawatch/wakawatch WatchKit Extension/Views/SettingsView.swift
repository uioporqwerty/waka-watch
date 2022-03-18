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
                ScrollViewReader { _ in
                    /* TODO: Figure out if this feature is necessary.
                       Showing configureable goals complication.
                    */
//                    NavigationLink(destination: DependencyInjection
//                                                .shared
//                                                .container
//                                                .resolve(ComplicationSettingsView.self)!) {
//                        Text(LocalizedStringKey("SettingsView_ComplicationsSettings_Text"))
//                    }

                    AsyncButton(action: {
                        try? await self.settingsViewModel.disconnect()
                    }) {
                        Text(LocalizedStringKey("SettingsView_Disconnect_Button"))
                    }

                    Text(self.settingsViewModel.appVersion)
                        .font(Font.footnote)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .onAppear {
            self.settingsViewModel.load()
            self.settingsViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: SettingsView.self))")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SettingsView.self)!
    }
}
