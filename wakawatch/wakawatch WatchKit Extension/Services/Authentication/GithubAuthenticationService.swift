import Foundation

final class GithubAuthenticationService {
    private var logManager: LogManager
    private var telemetry: TelemetryService
    private var tokenManager: TokenManager

    public let callbackURLScheme = "wakawatch"
    public let authorizationUrl: URL
    
    init(logManager: LogManager,
         telemetryService: TelemetryService,
         tokenManager: TokenManager
        ) {
        self.logManager = logManager
        self.telemetry = telemetryService
        self.tokenManager = tokenManager
        
        let githubClientId = Bundle.main.infoDictionary?["GITHUB_CLIENT_ID"] as? String
        let stateCode = SecurityUtility.secureRandomStateCode()
        UserDefaults.standard.set(stateCode, forKey: DefaultsKeys.githubStateCode)
        
        self.authorizationUrl = URL(string: "https://github.com/login/oauth/authorize?client_id=\(githubClientId!)&redirect_uri=\(self.callbackURLScheme)%3A%2F%2Foauth-callback&allow_signup=false&state=\(stateCode)")!
    }
    

    func getAccessToken(authorizationCode: String) async throws {
        
    }

    func disconnect() async throws {
        
    }

    func refreshAccessToken() async {
        
    }
    
    func isValidState(_ stateCode: String) -> Bool {
        let previousStateCode = UserDefaults.standard.string(forKey: DefaultsKeys.githubStateCode)
        
        return stateCode == previousStateCode
    }
}
