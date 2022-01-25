import RollbarNotifier


final class RollbarAPMService : APMService {
    func configure() {
        let config = RollbarConfig()
        config.destination.accessToken = Bundle.main.infoDictionary?["ROLLBAR_ACCESS_TOKEN"] as! String
        config.destination.environment = Bundle.main.infoDictionary?["ENVIRONMENT"] as! String
        
        Rollbar.initWithConfiguration(config)
    }
}
