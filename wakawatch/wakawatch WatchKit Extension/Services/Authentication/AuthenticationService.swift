import Foundation

final class AuthenticationService {
    private var logManager: LogManager
    private var telemetry: TelemetryService

    private var clientId: String?
    private var clientSecret: String?
    private let baseUrl = "https://wakatime.com/oauth"
    public let authorizationUrl: URL
    public let callbackURLScheme = "wakawatch"

    init(logManager: LogManager, telemetryService: TelemetryService) {
        self.logManager = logManager
        self.telemetry = telemetryService

        self.clientId = Bundle.main.infoDictionary?["CLIENT_ID"] as? String
        self.clientSecret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String

        // swiftlint:disable:next line_length
        self.authorizationUrl = URL(string: "\(self.baseUrl)/authorize?scope=email%2Cread_stats%2Cread_logged_time&response_type=code&redirect_uri=wakawatch%3A%2F%2Foauth-callback&client_id=\(self.clientId!)")!
    }

    func getAccessToken(authorizationCode: String) async throws -> AccessTokenResponse? {
        let url = URL(string: "\(self.baseUrl)/token")

        // swiftlint:disable:next line_length
        let data: Data = "client_id=\(self.clientId!)&client_secret=\(self.clientSecret!)&grant_type=authorization_code&code=\(authorizationCode)&redirect_uri=\(self.callbackURLScheme)://oauth-callback".data(using: .utf8)!

        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        request.httpMethod = "POST"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let urlResponse = response as? HTTPURLResponse

            if urlResponse?.statusCode ?? 0 >= 300 {
                self.logManager.errorMessage(data)
            }

            self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                              url: request.url?.absoluteString,
                                              statusCode: urlResponse?.statusCode.description)
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

        let url = URL(string: "\(self.baseUrl)/revoke")

        // swiftlint:disable:next line_length
        let data = "client_id=\(self.clientId!)&client_secret=\(self.clientSecret!)&token=\(accessToken)".data(using: .utf8)!

        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        request.httpMethod = "POST"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let urlResponse = response as? HTTPURLResponse

            if urlResponse?.statusCode ?? 0 >= 300 {
                self.logManager.errorMessage(data)
            }

            self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                              url: request.url?.absoluteString,
                                              statusCode: urlResponse?.statusCode.description)
        } catch {
            self.logManager.reportError(error)
        }
    }

    func refreshAccessToken() async {
        if !accessIsTokenExpiringOrExpired() {
            return
        }

        let defaults = UserDefaults.standard
        let refreshToken = defaults.string(forKey: DefaultsKeys.refreshToken)!

        let url = URL(string: "\(self.baseUrl)/token")

        // swiftlint:disable:next line_length
        let data = "client_id=\(self.clientId!)&client_secret=\(self.clientSecret!)&redirect_uri=\(self.callbackURLScheme)://oauth-callback&grant_type=refresh_token&refresh_token=\(refreshToken)".data(using: .utf8)!

        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        request.httpMethod = "POST"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let urlResponse = response as? HTTPURLResponse

            if urlResponse?.statusCode ?? 0 >= 300 {
                self.logManager.errorMessage(data)
            }

            self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                              url: request.url?.absoluteString,
                                              statusCode: urlResponse?.statusCode.description)
            let refreshTokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)

            let defaults = UserDefaults.standard
            defaults.set(refreshTokenResponse.access_token, forKey: DefaultsKeys.accessToken)
            defaults.set(refreshTokenResponse.refresh_token, forKey: DefaultsKeys.refreshToken)
            defaults.set(refreshTokenResponse.expires_at, forKey: DefaultsKeys.tokenExpiration)

            let message: [String: Any] = [
                ConnectivityMessageKeys.authorized: true,
                ConnectivityMessageKeys.accessToken: refreshTokenResponse.access_token,
                ConnectivityMessageKeys.refreshToken: refreshTokenResponse.refresh_token,
                ConnectivityMessageKeys.tokenExpiration: refreshTokenResponse.expires_at
            ]
            ConnectivityService.shared.sendMessage(message, delivery: .highPriority)
            ConnectivityService.shared.sendMessage(message, delivery: .guaranteed)
            ConnectivityService.shared.sendMessage(message, delivery: .failable)

        } catch {
            self.logManager.reportError(error)
        }
    }

    private func accessIsTokenExpiringOrExpired() -> Bool {
        let defaults = UserDefaults.standard
        let expirationDate = DateUtility.getDate(date: defaults.string(forKey: DefaultsKeys.tokenExpiration)!,
                                                 includeTime: true)!
        let now = Date.now
        let expiringDate = Calendar.current.date(byAdding: .hour, value: -1, to: expirationDate)!

        return now > expiringDate || now > expirationDate
    }
}
