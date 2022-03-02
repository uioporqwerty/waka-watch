import Foundation
import WatchConnectivity

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

    @objc func handleWatchAppInstallationStatus(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.isWatchAppInstalled = true
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
