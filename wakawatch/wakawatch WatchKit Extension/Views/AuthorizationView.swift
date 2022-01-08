import SwiftUI
import AuthenticationServices

let callbackURLScheme = "wakawatch"
let clientId = "59wzFIXtADCSV7Kff7Ck4aha"
let clientSecret = "sec_6M1lwwSuU8s6kZFBL84dBzXIzFHGaqsNVio9Bh1IbF4jha0pBS6dUvSq4fxjVKu6iya0SXKr5kCEIZ9W"

func connectToWakaTime() {
    guard let authURL = URL(string: "https://wakatime.com/oauth/authorize?client_id=\(clientId)&client_secret=\(clientSecret)&redirect_uri=\(callbackURLScheme)://oauth-callback&response_type=token&scope=email,read_logged_time,read_stats")
    else {
        print("Could not construct WakaTime authorization URL.")
        return
    }
    
    let authenticationSession = ASWebAuthenticationSession(
      url: authURL,
      callbackURLScheme: callbackURLScheme) { callbackURL, error in
          print("testing")
    }
    
    authenticationSession.start()
}

struct AuthorizationView: View {
    var body: some View {
        VStack {
            Button("Connect", action: connectToWakaTime)
        }
    }
}

struct AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationView()
    }
}
