import Foundation
final class SettingsViewModel {
    private let networkService: NetworkService
    private let logManager: LogManager
    
    public let telemetry: TelemetryService
    
    init(networkService: NetworkService,
         logManager: LogManager,
         telemetryService: TelemetryService) {
        self.networkService = networkService
        self.logManager = logManager
        self.telemetry = telemetryService
    }
    
    func disconnect() async throws {
        self.telemetry.recordViewEvent(elementName: "TAPPED: Disconnect button")
        
        do {
            try await networkService.disconnect()
            
            let message: [String: Any] = [
                DefaultsKeys.authorized: false,
                DefaultsKeys.accessToken: ""
            ]
            ConnectivityService.shared.sendMessage(message, delivery: .highPriority)
            ConnectivityService.shared.sendMessage(message, delivery: .guaranteed)
            ConnectivityService.shared.sendMessage(message, delivery: .failable)
            
            let defaults = UserDefaults.standard
            defaults.set("", forKey: DefaultsKeys.accessToken)
            defaults.set(false, forKey: DefaultsKeys.authorized)
            
            self.telemetry.recordNavigationEvent(from: String(describing: SettingsView.self), to: String(describing: ConnectView.self))
        }
        catch {
            self.logManager.reportError(error)
        }
    }
}
