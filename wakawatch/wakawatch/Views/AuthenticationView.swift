import SwiftUI
import BetterSafariView

struct AuthenticationView: View {
    private var authenticationViewModel: AuthenticationViewModel
    @AppStorage(DefaultsKeys.authorized) private var authorized = false
    
    @State private var startingWebAuthenticationSession = false
    
    init(viewModel: AuthenticationViewModel) {
        self.authenticationViewModel = viewModel
        self.authenticationViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: AuthenticationView.self))")
    }
    
    var body: some View {
        if !self.authorized {
            VStack {
                Button(action: { self.startingWebAuthenticationSession = true }) {
                    Text(LocalizedStringKey("AuthenticationView_Connect_Text"))
                        .frame(maxWidth: .infinity, minHeight: 34)
                }
                    .buttonStyle(.borderedProminent)
                    .webAuthenticationSession(isPresented: $startingWebAuthenticationSession) {
                    WebAuthenticationSession(
                        url: self.authenticationViewModel.authorizationUrl,
                        callbackURLScheme: self.authenticationViewModel.callbackURLScheme
                    ) { callbackURL, error in
                        guard error == nil, let successURL = callbackURL else {
                           return
                        }
                        
                        let oAuthCode = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.filter({$0.name == "code"}).first
                        guard let authorizationCode = oAuthCode?.value else {
                            //TODO: Display error is authorization code is missing.
                            return
                        }
                        
                        Task {
                            await self.authenticationViewModel.authenticate(authorizationCode: authorizationCode)
                            self.startingWebAuthenticationSession = false
                        }
                    }
                    .prefersEphemeralWebBrowserSession(false)
                }
            }
        }
        else {
            VStack {
                Text(LocalizedStringKey("AuthenticationView_Connected_Text"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                AsyncButton(action: {
                    await self.authenticationViewModel.disconnect()
                })
                {
                    Text(LocalizedStringKey("AuthenticationView_Disconnect_Button_Text"))
                        .frame(minHeight: 34)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(AuthenticationView.self)!
    }
}
