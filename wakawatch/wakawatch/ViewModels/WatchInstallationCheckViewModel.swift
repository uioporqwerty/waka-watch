import Foundation
import WatchConnectivity
import UIKit

final class WatchInstallationCheckViewModel: ObservableObject {
    @Published var isWatchAppInstalled = WCSession.default.isWatchAppInstalled

    public let telemetry: TelemetryService
    public let analytics: AnalyticsService
    private let logManager: LogManager

    init(telemetryService: TelemetryService,
         analyticsService: AnalyticsService,
         logManager: LogManager
        ) {
        self.telemetry = telemetryService
        self.analytics = analyticsService
        self.logManager = logManager
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleWatchAppInstallationStatus(_:)),
                                               name: Notification.Name("WatchAppInstallation"),
                                               object: nil
                                              )
    }

    func openAppleWatchApp() {
        self.analytics.track(event: "iOS Apple Watch App Opened")
        guard let appleWatchScheme = URL(string: "itms-watchs://bridge:root=GENERAL_LINK") else {
            self.logManager.errorMessage("Could not open Apple Watch app. Failed to construct URL.")
            return
        }

        if UIApplication.shared.canOpenURL(appleWatchScheme) {
            UIApplication.shared.open(appleWatchScheme)
        }
    }

    @objc func handleWatchAppInstallationStatus(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.isWatchAppInstalled = true
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
