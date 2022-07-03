import Foundation
import WatchConnectivity
import UIKit

final class WatchInstallationCheckViewModel: ObservableObject {
    @Published var isWatchAppInstalled = WCSession.default.isWatchAppInstalled

    public let telemetry: TelemetryService
    private let logManager: LogManager

    init(telemetryService: TelemetryService,
         logManager: LogManager
        ) {
        self.telemetry = telemetryService
        self.logManager = logManager
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleWatchAppInstallationStatus(_:)),
                                               name: Notification.Name("WatchAppInstallation"),
                                               object: nil
                                              )
    }

    func openAppleWatchApp() {
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
