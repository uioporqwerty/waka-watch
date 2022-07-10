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
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            Text(LocalizedStringKey("WatchInstallationCheckView_Instructions_Text"))
                                .lineSpacing(4)
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))

                            ProgressView()

                            Button(action: self.viewModel.openAppleWatchApp) {
                                Text(LocalizedStringKey("WatchInstallationView_OpenAppleWatch_ButtonLabel"))
                                    .frame(maxWidth: .infinity, minHeight: 34)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(EdgeInsets(top: 24, leading: 8, bottom: 0, trailing: 8))

                            Button(action: { self.viewModel.isWatchAppInstalled = true }) {
                                   Text(LocalizedStringKey("WatchInstallationView_AlreadyInstalled_ButtonLabel"))
                            }
                            .buttonStyle(.plain)
                            .padding(EdgeInsets(top: 24, leading: 8, bottom: 0, trailing: 8))
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
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
