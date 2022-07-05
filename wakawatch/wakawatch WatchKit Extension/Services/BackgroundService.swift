import Foundation
import WatchKit

final class BackgroundService: NSObject, URLSessionDownloadDelegate {
    var isStarted = false
    private let requestFactory: RequestFactory
    private let logManager: LogManager
    private let complicationService: ComplicationService
    private let notificationService: NotificationService
    private var pendingBackgroundTask: WKURLSessionRefreshBackgroundTask?
    private var backgroundSession: URLSession?

    init(requestFactory: RequestFactory,
         logManager: LogManager,
         complicationService: ComplicationService,
         notificationService: NotificationService
        ) {
        self.requestFactory = requestFactory
        self.logManager = logManager
        self.complicationService = complicationService
        self.notificationService = notificationService
        super.init()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInitialSchedule(_:)),
                                               name: Notification.Name("ScheduleBackgroundTasks"),
                                               object: nil
                                              )
    }

    func updateContent() {
        let complicationsUpdateRequest = self.requestFactory.makeComplicationsUpdateRequest()
        self.logManager.debugMessage("Complications url \(complicationsUpdateRequest.url?.absoluteString ?? "")",
                                     true)
        let config = URLSessionConfiguration.background(withIdentifier: "app.wakawatch.background-refresh")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true

        self.backgroundSession = URLSession(configuration: config,
                                 delegate: self,
                                 delegateQueue: nil)

        let backgroundTask = self.backgroundSession?.downloadTask(with: complicationsUpdateRequest)
        backgroundTask?.resume()
        self.isStarted = true
    }

    func handleDownload(_ backgroundTask: WKURLSessionRefreshBackgroundTask) {
        self.pendingBackgroundTask = backgroundTask
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        processFile(file: location)
    }

    func processFile(file: URL) {
        guard let data = try? Data(contentsOf: file) else {
            self.logManager.errorMessage("file could not be read as data")
            self.clearBackgroundTask()
            self.schedule()
            return
        }

        guard let backgroundUpdateResponse = try? JSONDecoder().decode(BackgroundUpdateResponse.self, from: data) else {
            self.logManager.errorMessage("Unable to decode response to Swift object")
            self.clearBackgroundTask()
            self.schedule()
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(backgroundUpdateResponse.totalTimeCodedInSeconds,
                    forKey: DefaultsKeys.complicationCurrentTimeCoded)
        self.complicationService.updateTimelines()

        self.notificationService.isPermissionGranted(onGrantedHandler: {
            self.notificationService.notifyGoalsAchieved(newGoals: backgroundUpdateResponse.goals)
        }, alwaysHandler: {
            self.clearBackgroundTask()
            self.schedule()
        })
    }

    func schedule() {
        let time = self.isStarted ? 15 * 60 : 60
        let nextInterval = TimeInterval(time)
        let preferredDate = Date.now.addingTimeInterval(nextInterval)
        self.logManager.debugMessage("Scheduling background update for \(preferredDate)", true)

        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: preferredDate,
                                                       userInfo: nil) { error in
            if error != nil {
                self.logManager.reportError(error!)
            }
        }
    }

    @objc func handleInitialSchedule(_ notification: NSNotification) {
        if !self.isStarted {
            self.logManager.debugMessage("Initial download not scheduled. Scheduling for the first time.", true)
            self.schedule()
        }
    }

    private func clearBackgroundTask() {
        if self.pendingBackgroundTask != nil {
            self.pendingBackgroundTask?.setTaskCompletedWithSnapshot(false)
            self.backgroundSession?.invalidateAndCancel()
            self.pendingBackgroundTask = nil
            self.backgroundSession = nil
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
