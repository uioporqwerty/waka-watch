import SwiftUI
import BetterSafariView

let callbackURLScheme = "wakawatch"
let clientId = "59wzFIXtADCSV7Kff7Ck4aha"
let clientSecret = "sec_c99U07N5CM91cWjDCu2OQqO8bpqUiwOlGWjnucUVq6oBuc6ED7AipV7uYP8bHuvgBnnVZ8mEhElUByF8" //TODO: Store securely.

struct AuthenticationView: View {
    @State private var startingWebAuthenticationSession = false
    @AppStorage(DefaultsKeys.authorized) private var authorized = false
    
    var body: some View {
        Group {
            if !authorized {
                VStack {
                    Button("Connect to WakaTime", action: { self.startingWebAuthenticationSession = true })
                        .webAuthenticationSession(isPresented: $startingWebAuthenticationSession) {
                        WebAuthenticationSession(
                            url: URL(string: "https://wakatime.com/oauth/authorize?scope=email%2Cread_stats&response_type=code&redirect_uri=wakawatch%3A%2F%2Foauth-callback&client_id=\(clientId)")!,
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
                            
                            let params = "client_id=\(clientId)&client_secret=\(clientSecret)&grant_type=authorization_code&code=\(authorizationCode)&redirect_uri=\(callbackURLScheme)://oauth-callback";
                            
                            request.httpBody = params.data(using: String.Encoding.utf8);
                            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                    if let error = error {
                                        print("Error took place \(error)")
                                        return
                                    }
                             
                                if let data = data, let response = String(data: data, encoding: .utf8) {
                                        let accessTokenResponse: AccessTokenResponse = try! JSONDecoder().decode(AccessTokenResponse.self, from: response.data(using: .utf8)!)
                                    
                                        let defaults = UserDefaults.standard
                                        authorized = true
                                        startingWebAuthenticationSession = false
                                        defaults.set(true, forKey: DefaultsKeys.authorized)
                                        defaults.set(accessTokenResponse.access_token, forKey: DefaultsKeys.accessToken) //TODO: Store securely
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
                    Text("Authenticated with WakaTime.")
                }
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
