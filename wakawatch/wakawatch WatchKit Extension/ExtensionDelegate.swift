import Foundation
import WatchKit

class ExtensionDelegate: NSObject, WKApplicationDelegate {
    private var backgroundService: BackgroundService?
    private var logManager: LogManager?
    private var apmService: RollbarAPMService?
    private var analyticsService: AnalyticsService?

    override init() {
        super.init()
        self.backgroundService = DependencyInjection.shared.container.resolve(BackgroundService.self)!
        self.logManager = DependencyInjection.shared.container.resolve(LogManager.self)!
        self.apmService = DependencyInjection.shared.container.resolve(RollbarAPMService.self)!
        self.analyticsService = DependencyInjection.shared.container.resolve(AnalyticsService.self)!
    }

    func isAuthorized() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: DefaultsKeys.authorized)
    }

    func applicationDidFinishLaunching() {
        if !isAuthorized() {
            return
        }

        if !(self.backgroundService?.isStarted ?? false) {
            self.backgroundService?.schedule()
        }
        
        let defaults = UserDefaults.standard
        guard let personId = defaults.string(forKey: DefaultsKeys.userId) else {
            return
        }
        
        self.apmService?.setPersonTracking(id: personId)
        self.analyticsService?.identifyUser(id: personId)
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        if !isAuthorized() {
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
