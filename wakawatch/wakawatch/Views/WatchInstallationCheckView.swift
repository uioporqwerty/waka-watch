import SwiftUI
import WatchConnectivity

struct WatchInstallationCheckView: View {
    @ObservedObject var viewModel: WatchInstallationCheckViewModel

    init(viewModel: WatchInstallationCheckViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if !self.viewModel.isWatchAppInstalled {
                Text(LocalizedStringKey("WatchInstallationCheckView_Instructions_Text"))

                ProgressView()
            } else {
                DependencyInjection.shared.container.resolve(AuthenticationView.self)!
            }
        }.onAppear {
            self.viewModel.telemetry.recordViewEvent(elementName: String(describing: WatchInstallationCheckView.self))
        }
    }
}

struct WatchInstallationCheckView_Previews: PreviewProvider {
    static var previews: some View {
        WatchInstallationCheckView(viewModel:
                                    DependencyInjection.shared.container.resolve(WatchInstallationCheckViewModel.self)!)
    }
}
