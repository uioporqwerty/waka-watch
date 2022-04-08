import Foundation
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    private var backgroundService: BackgroundService?
    private var logManager: LogManager?

    override init() {
        super.init()
        self.backgroundService = DependencyInjection.shared.container.resolve(BackgroundService.self)!
        self.logManager = DependencyInjection.shared.container.resolve(LogManager.self)!
    }

    func isAuthorized() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: DefaultsKeys.authorized)
    }

    func applicationDidFinishLaunching() {
        if isAuthorized() && !(self.backgroundService?.isStarted ?? false) {
            self.backgroundService?.schedule()
        }
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        if !isAuthorized() {
            self.logManager?.debugMessage("User is not authorized for handling background tasks.")
            return
        }

        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                self.backgroundService?.updateContent()
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                self.backgroundService?.handleDownload(urlSessionTask)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}
