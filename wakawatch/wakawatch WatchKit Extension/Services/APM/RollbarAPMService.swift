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

        guard let configuration = Rollbar.currentConfiguration() else {
            self.logManager.errorMessage("Rollbar configuration not set.")
            return
        }

        configuration.person = RollbarPerson(id: profile.id)
        self.logManager.debugMessage("Tracking person with id \(profile.id)")
    }
}
