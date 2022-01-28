import SwiftUI
import BetterSafariView

let callbackURLScheme = "wakawatch"

struct AuthenticationView: View {
    @State private var authorized = false
    @State private var startingWebAuthenticationSession = false
    @State private var accessTokenResponse: AccessTokenResponse?
    
    private var clientId: String?
    private var clientSecret: String?
    
    init() {
        print(ConnectivityService.shared)
        self.clientId = Bundle.main.infoDictionary?["CLIENT_ID"] as? String
        self.clientSecret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String
    }
    
    func isAuthorized() -> Bool {
        let defaults = UserDefaults.standard
        let isStoredAuthorized = defaults.bool(forKey: DefaultsKeys.authorized)
        return self.authorized || isStoredAuthorized
    }
    
    var body: some View {
        if !isAuthorized() {
            VStack {
                Button(action: { self.startingWebAuthenticationSession = true }) {
                    Text("Connect to WakaTime")
                        .frame(maxWidth: .infinity, minHeight: 34)
                }
                    .buttonStyle(.borderedProminent)
                    .webAuthenticationSession(isPresented: $startingWebAuthenticationSession) {
                    WebAuthenticationSession(
                        url: URL(string: "https://wakatime.com/oauth/authorize?scope=email%2Cread_stats%2Cread_logged_time&response_type=code&redirect_uri=wakawatch%3A%2F%2Foauth-callback&client_id=\(self.clientId!)")!,
                        callbackURLScheme: callbackURLScheme
                    ) { callbackURL, error in
                        guard error == nil, let successURL = callbackURL else {
                           return
                        }
                        
                        let oAuthCode = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.filter({$0.name == "code"}).first
                        guard let authorizationCode = oAuthCode?.value else { return }
                        
                        let url = URL(string: "https://wakatime.com/oauth/token")
                        var request = URLRequest(url: url!)
                        request.httpMethod = "POST"
                        
                        let params = "client_id=\(self.clientId!)&client_secret=\(self.clientSecret!)&grant_type=authorization_code&code=\(authorizationCode)&redirect_uri=\(callbackURLScheme)://oauth-callback";
                        
                        request.httpBody = params.data(using: String.Encoding.utf8);
                        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                if let error = error {
                                    print("Error took place \(error)")
                                    return
                                }
                         
                            if let data = data, let response = String(data: data, encoding: .utf8) {
                                    let accessTokenResponse: AccessTokenResponse = try! JSONDecoder().decode(AccessTokenResponse.self, from: response.data(using: .utf8)!)
                                
                                    self.startingWebAuthenticationSession = false
                                    self.authorized = true
                                    self.accessTokenResponse = accessTokenResponse
                                    
                                    let defaults = UserDefaults.standard
                                    defaults.set(accessTokenResponse.access_token, forKey: DefaultsKeys.accessToken)
                                    defaults.set(true, forKey: DefaultsKeys.authorized)
                                
                                    ConnectivityService.shared.sendAuthorizationMessage(accessTokenResponse: accessTokenResponse, delivery: .highPriority)
                                    ConnectivityService.shared.sendAuthorizationMessage(accessTokenResponse: accessTokenResponse, delivery: .guaranteed)
                                    ConnectivityService.shared.sendAuthorizationMessage(accessTokenResponse: accessTokenResponse, delivery: .failable)
                            }
                        }
                        task.resume()
                    }
                    .prefersEphemeralWebBrowserSession(false)
                }
            }
        }
        else {
            VStack {
                Text("Connected with WakaTime. Open Waka Watch on your Apple Watch.")
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                Button(action: {
                    guard let accessTokenResponse = self.accessTokenResponse else {
                        return
                    }
                    
                    ConnectivityService.shared.sendAuthorizationMessage(accessTokenResponse: accessTokenResponse, delivery: .highPriority)
                    ConnectivityService.shared.sendAuthorizationMessage(accessTokenResponse: accessTokenResponse, delivery: .guaranteed)
                    ConnectivityService.shared.sendAuthorizationMessage(accessTokenResponse: accessTokenResponse, delivery: .failable)
                })
                {
                    Text("Pair with Apple Watch again")
                        .frame(minHeight: 34)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
