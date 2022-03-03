import Foundation
import WatchKit

final class BackgroundService: NSObject, URLSessionDownloadDelegate {
    var isStarted = false
    private let requestFactory: RequestFactory
    private let logManager: LogManager
    private let complicationService: ComplicationService
    private var pendingBackgroundTasks = [WKURLSessionRefreshBackgroundTask]()

    init(requestFactory: RequestFactory,
         logManager: LogManager,
         complicationService: ComplicationService
        ) {
        self.requestFactory = requestFactory
        self.logManager = logManager
        self.complicationService = complicationService
        super.init()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInitialSchedule(_:)),
                                               name: Notification.Name("ScheduleBackgroundTasks"),
                                               object: nil
                                              )
    }

    func updateContent() {
        self.logManager.debugMessage("In BackgroundService updateContent")
        let summaryRequest = self.requestFactory.makeSummaryRequest()

        let config = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true

        let session = URLSession(configuration: config,
                                 delegate: self,
                                 delegateQueue: nil)

        let backgroundTask = session.downloadTask(with: summaryRequest)
        backgroundTask.resume()
        self.isStarted = true
        self.logManager.debugMessage("backgroundTask scheduled")
    }

    func handleDownload(_ backgroundTask: WKURLSessionRefreshBackgroundTask) {
        self.logManager.debugMessage("Handling finished download")
        let configuration = URLSessionConfiguration.background(withIdentifier: backgroundTask.sessionIdentifier)

        _ = URLSession(configuration: configuration,
                       delegate: self,
                       delegateQueue: nil)

        pendingBackgroundTasks.append(backgroundTask)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        processFile(file: location)
        self.logManager.debugMessage("Marking pending background tasks as completed.")

        self.pendingBackgroundTasks.forEach {
            $0.setTaskCompletedWithSnapshot(false)
        }
        self.schedule()
    }

    func processFile(file: URL) {
        if let data = try? Data(contentsOf: file),
           let summaryResponse = try? JSONDecoder().decode(SummaryResponse.self, from: data) {
            let defaults = UserDefaults.standard
            defaults.set(summaryResponse.cummulative_total?.seconds,
                        forKey: DefaultsKeys.complicationCurrentTimeCoded)
            self.complicationService.updateTimelines()
            self.logManager.debugMessage("Complication updated")
        }
    }

    func schedule() {
        let nextInterval = TimeInterval(self.isStarted ? 60 : 15 * 60)
        let preferredDate = Date.now.addingTimeInterval(nextInterval)

        self.logManager.debugMessage("Scheduled for \(preferredDate)")

        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: preferredDate,
                                                       userInfo: nil) { error in
            if error != nil {
                self.logManager.reportError(error!)
            }
        }
    }

    @objc func handleInitialSchedule(_ notification: NSNotification) {
        if !self.isStarted {
            self.schedule()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
