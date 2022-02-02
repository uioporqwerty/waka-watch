import Foundation

final class AuthenticationService {
    private var logManager: LogManager
    private var telemetry: TelemetryService
    
    private var clientId: String?
    private var clientSecret: String?
    
    public let authorizationUrl: URL
    public let callbackURLScheme = "wakawatch"
    
    init(logManager: LogManager, telemetryService: TelemetryService) {
        self.logManager = logManager
        self.telemetry = telemetryService
        
        self.clientId = Bundle.main.infoDictionary?["CLIENT_ID"] as? String
        self.clientSecret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String
        self.authorizationUrl = URL(string: "https://wakatime.com/oauth/authorize?scope=email%2Cread_stats%2Cread_logged_time&response_type=code&redirect_uri=wakawatch%3A%2F%2Foauth-callback&client_id=\(self.clientId!)")!
    }
    
    func getAccessToken(authorizationCode: String) async throws -> AccessTokenResponse? {
        let url = URL(string: "https://wakatime.com/oauth/token")
        let data: Data = "client_id=\(self.clientId!)&client_secret=\(self.clientSecret!)&grant_type=authorization_code&code=\(authorizationCode)&redirect_uri=\(self.callbackURLScheme)://oauth-callback".data(using: .utf8)!
        
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        request.httpMethod = "POST"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let urlResponse = response as! HTTPURLResponse
            
            if urlResponse.statusCode >= 300 {
                self.logManager.errorMessage(data)
            }

            self.telemetry.recordNetworkEvent(method: request.httpMethod, url: request.url?.absoluteString, statusCode: urlResponse.statusCode.description)
            let accessTokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
            
            return accessTokenResponse
        } catch {
            self.logManager.reportError(error)
        }
        
        return nil
    }
    
    func disconnect() async throws {
        let defaults = UserDefaults.standard
        let accessToken = defaults.string(forKey: DefaultsKeys.accessToken)!
        
        let url = URL(string: "https://wakatime.com/oauth/revoke")
        let data: Data = "client_id=\(self.clientId!)&client_secret=\(self.clientSecret!)&token=\(accessToken)".data(using: .utf8)!
        
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        request.httpMethod = "POST"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let urlResponse = response as! HTTPURLResponse
            
            if urlResponse.statusCode >= 300 {
                self.logManager.errorMessage(data)
            }
            
            self.telemetry.recordNetworkEvent(method: request.httpMethod, url: request.url?.absoluteString, statusCode: urlResponse.statusCode.description)
        } catch {
            self.logManager.reportError(error)
        }
    }
}
