import SwiftUI
import AuthenticationServices

let callbackURLScheme = "wakawatch"
let clientId = "59wzFIXtADCSV7Kff7Ck4aha"
let clientSecret = "sec_6M1lwwSuU8s6kZFBL84dBzXIzFHGaqsNVio9Bh1IbF4jha0pBS6dUvSq4fxjVKu6iya0SXKr5kCEIZ9W"


struct AuthorizationView: View {
    @State var authorized: Bool
    
    var body: some View {
        Group {
            if !authorized {
                VStack {
                    Button("Connect", action: connectToWakaTime)
                }
            } else {
                TabView {
                    SummaryView(totalDisplayTime: "4 mins")
                    LeaderboardView(leaderboardRecords: LeaderboardRecord.mockLeaderboard)
                    ProfileView(user: User.mockUsers[0], rank: 1)
                }
            }
        }
    }
    
    func connectToWakaTime() {
    //    let authURL = URL(string: "https://wakatime.com/oauth/authorize?client_id=\(clientId)&client_secret=\(clientSecret)&redirect_uri=\(callbackURLScheme)://oauth-callback&response_type=token&scope=email,read_logged_time,read_stats")
    //
    //    let authenticationSession = ASWebAuthenticationSession(
    //      url: authURL!,
    //      callbackURLScheme: callbackURLScheme) { callbackURL, error in
    //          print("testing")
    //    }
    //
    //    authenticationSession.start()
        authorized = true
        
    }
}

struct AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        let defaults = UserDefaults.standard
        AuthorizationView(authorized: defaults.bool(forKey: DefaultsKeys.authorized))
    }
}
