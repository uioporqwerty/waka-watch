import SwiftUI
import BetterSafariView

struct AuthenticationView: View {
    private var authenticationViewModel: AuthenticationViewModel
    @AppStorage(DefaultsKeys.authorized) private var authorized = false
    @Environment(\.openURL) var openURL

    @State private var startingWebAuthenticationSession = false
    @State private var requiresUpdate = false
    @State private var showFeatureRequestModal = false

    init(viewModel: AuthenticationViewModel) {
        self.authenticationViewModel = viewModel
    }

    var body: some View {
        VStack {
            if self.requiresUpdate {
                Text(LocalizedStringKey("ConnectView_UpdateRequired_Message"))
                    .multilineTextAlignment(.center)
            } else if !self.authorized {
                Button(action: { self.startingWebAuthenticationSession = true }) {
                    Text(LocalizedStringKey("AuthenticationView_Connect_Text"))
                        .frame(maxWidth: .infinity, minHeight: 34)
                }
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                .buttonStyle(.borderedProminent)
                .webAuthenticationSession(isPresented: $startingWebAuthenticationSession) {
                WebAuthenticationSession(
                    url: self.authenticationViewModel.authorizationUrl,
                    callbackURLScheme: self.authenticationViewModel.callbackURLScheme
                ) { callbackURL, error in
                    guard error == nil, let successURL = callbackURL else {
                       return
                    }
                    // swiftlint:disable line_length
                    let oAuthCode = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.filter({$0.name == "code"}).first
                    guard let authorizationCode = oAuthCode?.value else {
                        // TODO: Display error is authorization code is missing.
                        return
                    }

                    Task {
                        await self.authenticationViewModel.authenticate(authorizationCode: authorizationCode)
                        self.startingWebAuthenticationSession = false
                    }
                }
                .prefersEphemeralWebBrowserSession(true)
            }
        } else {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            Text(LocalizedStringKey("AuthenticationView_Connected_Text"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)

                            AsyncButton(action: {
                                await self.authenticationViewModel.disconnect()
                            }) {
                                Text(LocalizedStringKey("AuthenticationView_Disconnect_Button_Text"))
                                    .frame(maxWidth: .infinity, minHeight: 34)
                            }
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                            .buttonStyle(.borderedProminent)

                            Divider()
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                            Text(LocalizedStringKey("AuthenticationView_RequestFeature_Text"))
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                                .lineSpacing(4)

                            Button {
                                self.authenticationViewModel
                                    .telemetry
                                    .recordViewEvent(elementName: "\(String(describing: AuthenticationView.self))_RequestFeature_Button")
                                self.showFeatureRequestModal = true
                            }
                            label: {
                                Text(LocalizedStringKey("AuthenticationView_RequestFeature_Button_Label"))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                            }
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                            .fullScreenCover(isPresented: self.$showFeatureRequestModal) {
                                FeatureRequestView(viewModel: DependencyInjection.shared.container.resolve(FeatureRequestViewModel.self)!)
                            }

                            Divider()
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                            Text(LocalizedStringKey("AuthenticationView_Donation_Text"))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                            .lineSpacing(4)

                            Button {
                                self.authenticationViewModel
                                    .telemetry
                                    .recordViewEvent(elementName: "\(String(describing: AuthenticationView.self))_Donation_Button")
                                openURL(URL(string: "https://funds.effectivealtruism.org/donate/organizations")!)
                            }
                            label: {
                                Label(LocalizedStringKey("AuthenticationView_Donation_Button_Label"), systemImage: "heart.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.displayP3, red: 171/255, green: 43/255, blue: 36/255, opacity: 1))
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                            }
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
        }
        .onAppear {
            self.authenticationViewModel
                .telemetry
                .recordViewEvent(elementName: "\(String(describing: AuthenticationView.self))")
        }
        .task {
            self.requiresUpdate = await self.authenticationViewModel.requiresUpdate()
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(AuthenticationView.self)!
    }
}
