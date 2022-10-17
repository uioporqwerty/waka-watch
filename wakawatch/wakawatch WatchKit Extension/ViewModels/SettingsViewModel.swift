import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var appVersion: String = ""
    @Published var analyticsOptInOptOutButtonLabel: String = ""
    @Published var showEnableNotificationsButton = false
    private var optedOut: Bool
    
    private let networkService: NetworkService
    private let notificationService: NotificationService
    private let authenticationService: AuthenticationService
    private let tokenManager: TokenManager
    
    public let logManager: LogManager
    public let telemetry: TelemetryService
    public let analytics: AnalyticsService
    
    init(networkService: NetworkService,
         notificationService: NotificationService,
         authenticationService: AuthenticationService,
         logManager: LogManager,
         telemetryService: TelemetryService,
         analyticsService: AnalyticsService,
         tokenManager: TokenManager
        ) {
        self.networkService = networkService
        self.notificationService = notificationService
        self.authenticationService = authenticationService
        self.logManager = logManager
        self.telemetry = telemetryService
        self.analytics = analyticsService
        self.tokenManager = tokenManager
        self.optedOut = self.analytics.hasOptedOut()
    }

    func load() {
        self.shouldShowEnableNotificationsButton()
        DispatchQueue.main.async {
            guard let version =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                  let buildNumber =  Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
                      return
                  }
            self.appVersion = "v\(version) (\(buildNumber))"
            
            self.analyticsOptInOptOutButtonLabel = self.optedOut ?
                LocalizedStringKey("SettingsView_ToggleMixpanel_OptInButtonLabel").toString() :
                LocalizedStringKey("SettingsView_ToggleMixpanel_OptOutButtonLabel").toString()
        }
    }

    func disconnect() async throws {
        self.telemetry.recordViewEvent(elementName: "TAPPED: Disconnect button")
        self.analytics.track(event: "Disconnect")
        
        do {
            try await self.authenticationService.disconnect()

            self.telemetry
                .recordNavigationEvent(from: String(describing: SettingsView.self),
                                       to: String(describing: ConnectView.self))
        } catch {
            self.logManager.reportError(error)
        }
    }
    
    func promptPermissions() {
        self.analytics.track(event: "Prompted for Permissions")
        self.notificationService.requestAuthorization(authorizedHandler: {
            self.shouldShowEnableNotificationsButton()
        }) {
            self.shouldShowEnableNotificationsButton()
        }
    }
    
    func analyticsOptInOptOut() {
        self.analytics.toggleOptInOptOut()
        self.optedOut = !self.optedOut
        
        DispatchQueue.main.async {
            self.analyticsOptInOptOutButtonLabel = self.optedOut ?
                LocalizedStringKey("SettingsView_ToggleMixpanel_OptInButtonLabel").toString() :
                LocalizedStringKey("SettingsView_ToggleMixpanel_OptOutButtonLabel").toString()
        }
    }
    
    private func shouldShowEnableNotificationsButton() {
       self.notificationService.isPermissionGranted(onGrantedHandler: {
            self.showEnableNotificationsButton = false
        },
        onNotDeterminedHandler: {
            DispatchQueue.main.async {
                self.showEnableNotificationsButton = true
            }
        })
    }
}
