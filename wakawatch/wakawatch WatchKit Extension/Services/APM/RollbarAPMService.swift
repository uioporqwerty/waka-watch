import RollbarNotifier
import Foundation

class RollbarAPMService {
    init() {
        let config = RollbarConfig()
        config.destination.accessToken = Bundle.main.infoDictionary?["ROLLBAR_ACCESS_TOKEN"] as? String ?? ""
        config.destination.environment = Bundle.main.infoDictionary?["ENVIRONMENT"] as? String ?? "Development"
        config.telemetry.captureLog = true
        config.telemetry.enabled = true
        config.developerOptions.transmit = true

        Rollbar.initWithConfiguration(config)
    }
}
