import SwiftUI

struct SettingsView: View {
    private var settingsViewModel = SettingsViewModel()
    @State var isActive = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { value in
                AsyncButton(action: {
                    do {
                        try await self.settingsViewModel.disconnect()
                        ConnectivityService.shared.authorized = false
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
        SettingsView()
    }
}
