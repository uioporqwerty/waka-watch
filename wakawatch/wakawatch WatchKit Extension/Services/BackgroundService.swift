import Foundation
import WatchKit

final class BackgroundService: NSObject, URLSessionDownloadDelegate {
    var isStarted = false
    private let requestFactory: RequestFactory
    private let logManager: LogManager
    private let complicationService: ComplicationService
    private var pendingBackgroundTask: WKURLSessionRefreshBackgroundTask?
    private var backgroundSession: URLSession?

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
        let complicationsUpdateRequest = self.requestFactory.makeComplicationsUpdateRequest()

        let config = URLSessionConfiguration.background(withIdentifier: "app.wakawatch.background-refresh")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true

        self.backgroundSession = URLSession(configuration: config,
                                 delegate: self,
                                 delegateQueue: nil)

        let backgroundTask = self.backgroundSession?.downloadTask(with: complicationsUpdateRequest)
        backgroundTask?.resume()
        self.isStarted = true
        self.logManager.debugMessage("backgroundTask scheduled")
    }

    func handleDownload(_ backgroundTask: WKURLSessionRefreshBackgroundTask) {
        self.logManager.debugMessage("Handling finished download")
        self.pendingBackgroundTask = backgroundTask
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        processFile(file: location)
        self.logManager.debugMessage("Marking pending background tasks as completed.")

        if self.pendingBackgroundTask != nil {
            self.pendingBackgroundTask?.setTaskCompletedWithSnapshot(false)
            self.backgroundSession?.finishTasksAndInvalidate()
            self.pendingBackgroundTask = nil
            self.backgroundSession = nil
            self.logManager.debugMessage("Pending background task cleared")
        }

        self.schedule()
    }

    func processFile(file: URL) {
        guard let data = try? Data(contentsOf: file) else {
            self.logManager.errorMessage("file could not be read as data")
            return
        }

        guard let complicationsResponse = try? JSONDecoder().decode(ComplicationsUpdateResponse.self, from: data) else {
            print(String(decoding: data, as: UTF8.self))
            self.logManager.errorMessage("Unable to decode response to Swift object")
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(complicationsResponse.totalTimeCodedInSeconds,
                    forKey: DefaultsKeys.complicationCurrentTimeCoded)
        self.complicationService.updateTimelines()
        self.logManager.debugMessage("Complication updated")
    }

    func schedule() {
        let nextInterval = TimeInterval(60)
        let preferredDate = Date.now.addingTimeInterval(nextInterval)

        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: preferredDate,
                                                       userInfo: nil) { error in
            if error != nil {
                self.logManager.reportError(error!)
                return
            }

            self.logManager.debugMessage("Scheduled for \(preferredDate)")
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
