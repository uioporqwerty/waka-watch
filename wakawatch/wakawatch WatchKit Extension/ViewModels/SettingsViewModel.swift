import Foundation
final class SettingsViewModel {
    private var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func disconnect() async throws {
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
        }
        catch {
            print("Failed to disconnect with error: \(error)")
        }
    }
}
