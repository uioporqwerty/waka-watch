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
        self.logManager?.debugMessage("In applicationDidFinishLaunching")
        if isAuthorized() && !(self.backgroundService?.isStarted ?? false) {
            self.backgroundService?.schedule()
        }
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        self.logManager?.debugMessage("In handle backgroundTasks")
        if !isAuthorized() {
            return
        }

        for task in backgroundTasks {
            self.logManager?.debugMessage("Processing task: \(task.debugDescription)")
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
