import RollbarNotifier
import Foundation

class RollbarAPMService: APMService {
    private var networkService: NetworkService
    private var logManager: LogManager

    init(networkService: NetworkService,
         logManager: LogManager) {
        self.networkService = networkService
        self.logManager = logManager

        let config = RollbarConfig()
        config.destination.accessToken = Bundle.main.infoDictionary?["ROLLBAR_ACCESS_TOKEN"] as? String ?? ""
        config.destination.environment = Bundle.main.infoDictionary?["ENVIRONMENT"] as? String ?? "Development"
        config.telemetry.captureLog = true
        config.telemetry.enabled = true
        config.developerOptions.transmit = true

        Rollbar.initWithConfiguration(config)
    }

    func setUser() async {
        let profileData = try? await self.networkService.getProfileData(userId: nil)
        guard let profile = profileData?.data else {
            self.logManager.errorMessage("Failed to find profile for current user. Cannot set user.")
            return
        }

        // swiftlint:disable line_length
        self.logManager.debugMessage("Setting Rollbar user with email \(profile.email ?? ""), id \(profile.id), and display_name \(profile.display_name ?? "")")
        Rollbar.currentConfiguration()?.setPersonId(profile.id, username: profile.display_name ?? "", email: profile.email ?? "")
    }
}
