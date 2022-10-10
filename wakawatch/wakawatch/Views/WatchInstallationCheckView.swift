import SwiftUI
import WatchConnectivity
import AVKit

struct WatchInstallationCheckView: View {
    @ObservedObject var viewModel: WatchInstallationCheckViewModel
    @State private var player = AVQueuePlayer()
    
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
                                .padding(EdgeInsets(top: 24, leading: 8, bottom: 0, trailing: 8))

                            Button(action: {
                                self.viewModel.openAppleWatchApp()
                            }) {
                                Text(LocalizedStringKey("WatchInstallationView_OpenAppleWatch_ButtonLabel"))
                                    .frame(maxWidth: .infinity, minHeight: 34)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(EdgeInsets(top: 24, leading: 8, bottom: 0, trailing: 8))
                            
                            PlayerView(videoName: "Waka-Watch-Installation",
                                       player: player)
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: geometry.size.width,
                                   maxHeight: geometry.size.height)
                            .onAppear {
                                player.play()
                            }
                            .onDisappear {
                                player.pause()
                            }
                            .onReceive(NotificationCenter
                                       .default
                                       .publisher(for: UIApplication.willResignActiveNotification)) { _ in
                                player.pause()
                            }
                            .onReceive(NotificationCenter
                                       .default
                                       .publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                                player.play()
                            }
                            .padding(EdgeInsets(top: 24, leading: 8, bottom: 0, trailing: 8))
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            } else {
                DependencyInjection.shared.container.resolve(AuthenticationView.self)!
            }
        }
        .onAppear {
            self.viewModel
                .telemetry
                .recordViewEvent(elementName: String(describing: WatchInstallationCheckView.self))
            self.viewModel
                .analytics
                .track(event: "Watch Installation View Shown")
        }
    }
}

struct WatchInstallationCheckView_Previews: PreviewProvider {
    static var previews: some View {
        WatchInstallationCheckView(viewModel:
                                    DependencyInjection.shared.container.resolve(WatchInstallationCheckViewModel.self)!)
    }
}
