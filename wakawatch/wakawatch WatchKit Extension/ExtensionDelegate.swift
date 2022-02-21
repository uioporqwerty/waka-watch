import Foundation
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, URLSessionDownloadDelegate {
    private var complicationService: ComplicationService?
    private var logManager: LogManager?
    private var requestFactory: RequestFactory?

    private var completionHandler: ((_ update: Bool) -> Void)?
    private var backgroundTask: URLSessionDownloadTask?

    private lazy var backgroundURLSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "BackgroundSummary")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true

        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    override init() {
        super.init()
        self.complicationService = DependencyInjection.shared.container.resolve(ComplicationService.self)!
        self.logManager = DependencyInjection.shared.container.resolve(LogManager.self)!
        self.requestFactory = DependencyInjection.shared.container.resolve(RequestFactory.self)!
    }

    func applicationDidFinishLaunching() {
        self.schedule(true)
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        self.logManager?.debugMessage("Handling background tasks")
        for task in backgroundTasks {
            self.logManager?.debugMessage("Processing task: \(task.debugDescription)")
            switch task {
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                self.refresh { update in
                    self.logManager?.debugMessage("Refresh completed with update status \(update)")
                    self.schedule(false)
                    if update {
                        self.logManager?.debugMessage("Updating active complications")
                        self.complicationService?.updateTimelines()
                    }
                    urlSessionTask.setTaskCompletedWithSnapshot(false)
                }
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        self.logManager?.debugMessage("In urlSession didFinishDownloadingTo")
        if location.isFileURL {
            do {
                let data = try Data(contentsOf: location)
                let summaryResponse = try JSONDecoder().decode(SummaryResponse.self, from: data)
                self.logManager?.debugMessage("summaryResponse for background update \(summaryResponse)")
                let defaults = UserDefaults.standard
                defaults.set(summaryResponse.cummulative_total?.seconds?.toHourMinuteFormat,
                             forKey: DefaultsKeys.complicationCurrentTimeCoded)
            } catch {
                self.logManager?.errorMessage("\(error)")
            }
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        self.logManager?.debugMessage("In urlSession didCompleteWithError")
        if error != nil {
            self.logManager?.errorMessage(error.debugDescription)
        }

        DispatchQueue.main.async {
            self.completionHandler?(error == nil)
            self.completionHandler = nil
            self.backgroundTask = nil
        }
    }

    func schedule(_ first: Bool) {
        guard let summaryRequest = self.requestFactory?.makeSummaryRequest() else {
            return
        }

        if self.backgroundTask == nil {
            let task = self.backgroundURLSession.downloadTask(with: summaryRequest)
            let nextInterval = first ? 60 : 15 * 60
            self.logManager?.debugMessage("Current time is \(Date.now)")
            self.logManager?.debugMessage("Scheduling \(nextInterval) seconds from now")
            task.earliestBeginDate = Date.now.addingTimeInterval(first ? 60 : 15 * 60)
            self.logManager?.debugMessage("Scheduled for \(String(describing: task.earliestBeginDate))")
            task.resume()
            self.backgroundTask = task
        }
    }

    func refresh(_ completionHandler: @escaping (_ update: Bool) -> Void) {
        self.logManager?.debugMessage("In refresh")
        self.completionHandler = completionHandler
    }
}
