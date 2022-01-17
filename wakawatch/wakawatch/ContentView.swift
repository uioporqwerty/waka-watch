import SwiftUI
import AuthenticationServices
import BetterSafariView

let callbackURLScheme = "wakawatch"
let clientId = "59wzFIXtADCSV7Kff7Ck4aha"
let clientSecret = "sec_c99U07N5CM91cWjDCu2OQqO8bpqUiwOlGWjnucUVq6oBuc6ED7AipV7uYP8bHuvgBnnVZ8mEhElUByF8"

struct ContentView: View {
    @State private var startingWebAuthenticationSession = false
    
    var body: some View {
        Button("Connect", action: { self.startingWebAuthenticationSession = true })
                                .webAuthenticationSession(isPresented: $startingWebAuthenticationSession) {
                                WebAuthenticationSession(
                                    url: URL(string: "https://wakatime.com/oauth/authorize?scope=email%2Cread_stats&response_type=code&state=e12df671bf011d5d8c4c41bc45b359f4a7ce49a5&redirect_uri=wakawatch%3A%2F%2Foauth-callback&client_id=59wzFIXtADCSV7Kff7Ck4aha")!,
                                    callbackURLScheme: callbackURLScheme
                                ) { callbackURL, error in
                                    guard error == nil, let successURL = callbackURL else {
                                       return
                                    }
                                    
                                    let oauthToken = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.filter({$0.name == "code"}).first
                                    print(oauthToken ?? "No OAuth Token")
                                    
                                    let defaults = UserDefaults.standard
//                                    authorized = true
//                                    defaults.set(true, forKey: DefaultsKeys.authorized)
                                }
                                .prefersEphemeralWebBrowserSession(false)
                            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
