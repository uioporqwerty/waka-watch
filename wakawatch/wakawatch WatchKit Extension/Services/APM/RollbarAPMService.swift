import RollbarNotifier
import Foundation

class RollbarAPMService: APMService {
    private var configuration: RollbarConfig
    private var networkService: NetworkService
    private var logManager: LogManager

    init(networkService: NetworkService,
         logManager: LogManager) {
        self.configuration = RollbarConfig()
        self.networkService = networkService
        self.logManager = logManager
        self.configuration.destination.accessToken = Bundle.main.infoDictionary?["ROLLBAR_ACCESS_TOKEN"] as? String
                                                                                                         ?? ""
        self.configuration.destination.environment = Bundle.main.infoDictionary?["ENVIRONMENT"] as? String
                                                                                                ?? "Development"

        Rollbar.initWithConfiguration(self.configuration)
    }

    func setUser() async {
        let profileData = await self.networkService.getProfileData(userId: nil)
        guard let profile = profileData?.data else {
            self.logManager.errorMessage("Failed to find profile for current user. Cannot set user.")
            return
        }

        // swiftlint:disable line_length
        self.logManager.debugMessage("Setting Rollbar user with email \(profile.email ?? ""), id \(profile.id), and display_name \(profile.display_name ?? "")")
        self.configuration.setPersonId(profile.id, username: profile.display_name ?? "", email: profile.email ?? "")
        Rollbar.updateConfiguration(self.configuration)
        Rollbar.reapplyConfiguration()
    }
}
