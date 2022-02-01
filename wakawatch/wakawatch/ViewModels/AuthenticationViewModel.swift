import Foundation

final class AuthenticationViewModel {
    private let authenticationService: AuthenticationService
    
    public let telemetry: TelemetryService
    public let authorizationUrl: URL
    public let callbackURLScheme: String
    
    init(authenticationService: AuthenticationService,
         telemetryService: TelemetryService) {
        self.authenticationService = authenticationService
        self.telemetry = telemetryService
        
        self.authorizationUrl = self.authenticationService.authorizationUrl
        self.callbackURLScheme = self.authenticationService.callbackURLScheme
    }
    
    func authenticate(authorizationCode: String) async {
        Task {
            do {
                let accessTokenResponse = try await authenticationService.getAccessToken(authorizationCode: authorizationCode)
                
                guard let accessTokenResponse = accessTokenResponse else {
                    return
                }
 
                let defaults = UserDefaults.standard
                defaults.set(accessTokenResponse.access_token, forKey: DefaultsKeys.accessToken)
                defaults.set(true, forKey: DefaultsKeys.authorized)
                
                let message: [String: Any] = [
                    DefaultsKeys.authorized: true,
                    DefaultsKeys.accessToken: accessTokenResponse.access_token
                ]
                ConnectivityService.shared.sendMessage(message, delivery: .highPriority)
                ConnectivityService.shared.sendMessage(message, delivery: .guaranteed)
                ConnectivityService.shared.sendMessage(message, delivery: .failable)
            } catch {
                print("Failed to get summary with error: \(error)")
            }
        }
    }
}
