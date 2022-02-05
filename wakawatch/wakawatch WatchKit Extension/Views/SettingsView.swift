import SwiftUI

struct SettingsView: View {
    private var settingsViewModel: SettingsViewModel
    @State var isActive = false

    init(viewModel: SettingsViewModel) {
        self.settingsViewModel = viewModel
        self.settingsViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: SettingsView.self))")
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { _ in
                AsyncButton(action: {
                    do {
                        try await self.settingsViewModel.disconnect()
                    } catch { }
                }) {
                    Text(LocalizedStringKey("SettingsView_Disconnect_Button"))
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SettingsView.self)!
    }
}
