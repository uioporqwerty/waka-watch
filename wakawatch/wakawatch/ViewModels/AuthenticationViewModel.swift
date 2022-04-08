import Foundation
import RollbarNotifier

final class AuthenticationViewModel {
    private let authenticationService: AuthenticationService
    private let networkService: NetworkService
    private let logManager: LogManager

    public let telemetry: TelemetryService
    public let authorizationUrl: URL
    public let callbackURLScheme: String

    init(authenticationService: AuthenticationService,
         networkService: NetworkService,
         telemetryService: TelemetryService,
         logManager: LogManager) {
        self.authenticationService = authenticationService
        self.networkService = networkService
        self.telemetry = telemetryService
        self.logManager = logManager

        self.authorizationUrl = self.authenticationService.authorizationUrl
        self.callbackURLScheme = self.authenticationService.callbackURLScheme
    }

    func authenticate(authorizationCode: String) async {
        Task {
            do {
                self.telemetry.recordViewEvent(elementName: "TAPPED: Connect with WakaTime button on companion app")
                let accessTokenResponse = try await authenticationService
                                                    .getAccessToken(authorizationCode: authorizationCode)

                guard let accessTokenResponse = accessTokenResponse else {
                    return
                }

                let defaults = UserDefaults.standard
                defaults.set(accessTokenResponse.access_token, forKey: DefaultsKeys.accessToken)
                defaults.set(accessTokenResponse.refresh_token, forKey: DefaultsKeys.refreshToken)
                defaults.set(accessTokenResponse.expires_at, forKey: DefaultsKeys.tokenExpiration)
                defaults.set(true, forKey: DefaultsKeys.authorized)

                let message: [String: Any] = [
                    ConnectivityMessageKeys.authorized: true,
                    ConnectivityMessageKeys.accessToken: accessTokenResponse.access_token,
                    ConnectivityMessageKeys.refreshToken: accessTokenResponse.refresh_token,
                    ConnectivityMessageKeys.tokenExpiration: accessTokenResponse.expires_at
                ]
                ConnectivityService.shared.sendMessage(message, delivery: .highPriority)
                ConnectivityService.shared.sendMessage(message, delivery: .guaranteed)
                ConnectivityService.shared.sendMessage(message, delivery: .failable)

                let profileData = try? await self.networkService.getProfileData(userId: nil)
                guard let profile = profileData?.data else {
                    self.logManager.errorMessage("Failed to find profile for current user. Cannot set user.")
                    return
                }

                guard let configuration = Rollbar.currentConfiguration() else {
                    self.logManager.errorMessage("Rollbar configuration not set.")
                    return
                }

                configuration.person = RollbarPerson(id: profile.id)
            } catch {
                self.logManager.reportError(error)
            }
        }
    }

    func disconnect() async {
        do {
            self.telemetry.recordViewEvent(elementName: "TAPPED: Disconnect button on companion app")
            try await self.authenticationService.disconnect()

            // TODO: Repeated logic in SettingsViewModel, refactor.
            let message: [String: Any] = [
                ConnectivityMessageKeys.authorized: false,
                ConnectivityMessageKeys.accessToken: "",
                ConnectivityMessageKeys.refreshToken: "",
                ConnectivityMessageKeys.tokenExpiration: ""
            ]
            ConnectivityService.shared.sendMessage(message, delivery: .highPriority)
            ConnectivityService.shared.sendMessage(message, delivery: .guaranteed)
            ConnectivityService.shared.sendMessage(message, delivery: .failable)

            let defaults = UserDefaults.standard
            defaults.set("", forKey: DefaultsKeys.accessToken)
            defaults.set("", forKey: DefaultsKeys.refreshToken)
            defaults.set(false, forKey: DefaultsKeys.authorized)
        } catch {
            self.logManager.reportError(error)
        }
    }

    func requiresUpdate() async -> Bool {
        #if DEBUG
            return false
        #else
            let appInformation = try? await self.networkService.getAppInformation()
            let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

            guard let appInformation = appInformation else {
                return false
            }

            return VersionCheckerUtility.meetsMinimumVersion(currentVersion: currentAppVersion,
                                                             minimumVersion: appInformation.minimum_version)
        #endif
    }
}
