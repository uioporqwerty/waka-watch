import RollbarNotifier
import Foundation

class RollbarAPMService {
    private var logManager: LogManager

    init(logManager: LogManager) {
        self.logManager = logManager

        let config = RollbarConfig()
        config.dataScrubber.scrubFields = ["CLIENT_ID",
                                           "CLIENT_SECRET",
                                           "client_secret",
                                           "access_token",
                                           "refresh_token"]
        config.dataScrubber.enabled = true
        config.destination.accessToken = Bundle.main.infoDictionary?["ROLLBAR_ACCESS_TOKEN"] as? String ?? ""
        config.destination.environment = Bundle.main.infoDictionary?["ENVIRONMENT"] as? String ?? "Development"
        config.loggingOptions.captureIp = .anonymize
        config.telemetry.captureLog = true
        config.telemetry.captureConnectivity = true
        config.telemetry.enabled = true

        Rollbar.initWithConfiguration(config)
    }

    func setPersonTracking(id: String) {
        guard let config = Rollbar.currentConfiguration() else {
            self.logManager.errorMessage("Rollbar configuration not set.")
            return
        }
        config.person = RollbarPerson(id: id)
    }

    func isPersonTrackingSet() -> Bool {
        guard let config = Rollbar.currentConfiguration() else {
            self.logManager.errorMessage("Rollbar configuration not set.")
            return false
        }

        return config.person.id.isEmpty
    }
}
