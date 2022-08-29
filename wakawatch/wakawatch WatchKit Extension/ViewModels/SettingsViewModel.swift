import Foundation
final class SettingsViewModel: ObservableObject {
    @Published var appVersion: String = ""
    @Published var showEnableNotificationsButton = false
    
    private let networkService: NetworkService
    private let notificationService: NotificationService
    private let authenticationService: AuthenticationService
    private let tokenManager: TokenManager
    
    public let logManager: LogManager
    public let telemetry: TelemetryService

    init(networkService: NetworkService,
         notificationService: NotificationService,
         authenticationService: AuthenticationService,
         logManager: LogManager,
         telemetryService: TelemetryService,
         tokenManager: TokenManager
        ) {
        self.networkService = networkService
        self.notificationService = notificationService
        self.authenticationService = authenticationService
        self.logManager = logManager
        self.telemetry = telemetryService
        self.tokenManager = tokenManager
    }

    func load() {
        self.shouldShowEnableNotificationsButton()
        
        DispatchQueue.main.async {
            guard let version =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                  let buildNumber =  Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
                      return
                  }
            self.appVersion = "v\(version) (\(buildNumber))"
        }
    }

    func disconnect() async throws {
        self.telemetry.recordViewEvent(elementName: "TAPPED: Disconnect button")

        do {
            try await self.authenticationService.disconnect()

            let message: [String: Any] = [
                ConnectivityMessageKeys.authorized: false,
                ConnectivityMessageKeys.accessToken: "",
                ConnectivityMessageKeys.refreshToken: "",
                ConnectivityMessageKeys.tokenExpiration: ""
            ]
            ConnectivityService.shared.sendMessage(message, delivery: .highPriority)
            ConnectivityService.shared.sendMessage(message, delivery: .guaranteed)
            ConnectivityService.shared.sendMessage(message, delivery: .failable)

            self.telemetry
                .recordNavigationEvent(from: String(describing: SettingsView.self),
                                       to: String(describing: ConnectView.self))
        } catch {
            self.logManager.reportError(error)
        }
    }
    
    func promptPermissions() {
        self.notificationService.requestAuthorization()
    }
    
    private func shouldShowEnableNotificationsButton() {
        self.notificationService.isPermissionGranted(onNotDeterminedHandler: {
            DispatchQueue.main.async {
                self.showEnableNotificationsButton = true
            }
        })
    }
}
