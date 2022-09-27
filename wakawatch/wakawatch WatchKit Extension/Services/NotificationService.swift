import UserNotifications
import SwiftUI

final class NotificationService {
    private let center: UNUserNotificationCenter
    private let logManager: LogManager
    private let analytics: AnalyticsService

    init(logManager: LogManager,
         analyticsService: AnalyticsService
        ) {
        self.center = UNUserNotificationCenter.current()
        self.logManager = logManager
        self.analytics = analyticsService
    }

    func requestAuthorization(authorizedHandler: (() -> Void)? = nil) {
        self.center.requestAuthorization(options: [.alert, .sound, .provisional]) { granted, error in
            if let error = error {
                self.logManager.reportError(error)
                return
            }

            if !granted {
                return
            }

            authorizedHandler?()
        }
    }

    func isPermissionGranted(onGrantedHandler: (() -> Void)? = nil,
                             alwaysHandler: (() -> Void)? = nil,
                             onNotDeterminedHandler: (() -> Void)? = nil
                            ) {
        self.center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                self.logManager.debugMessage("Notification status is \(settings.authorizationStatus)", true)
                onGrantedHandler?()
            }
            if settings.authorizationStatus == .notDetermined {
                onNotDeterminedHandler?()
            }
            alwaysHandler?()
        }
    }

    private func storeGoals(_ goals: [ComplicationsUpdateGoalsResponse]) {
        let defaults = UserDefaults.standard

        do {
            try defaults.setObject(goals, forKey: DefaultsKeys.userGoals)
            self.logManager.debugMessage("Goal stored in defaults", true)
        } catch {
            self.logManager.errorMessage(error.localizedDescription)
        }
    }

    // swiftlint:disable:next function_body_length
    func notifyGoalsAchieved(newGoals: [ComplicationsUpdateGoalsResponse],
                             completionHandler: (() -> Void)? = nil) {
        let defaults = UserDefaults.standard
        var currentGoals: [ComplicationsUpdateGoalsResponse]?
        do {
            currentGoals = try defaults.getObject(forKey: DefaultsKeys.userGoals,
                                                  castTo: Array<ComplicationsUpdateGoalsResponse>.self)
            self.logManager.debugMessage("currentGoals = \(currentGoals ?? [])", true)
        } catch { // User does not have any stored goals for the first time.
            self.logManager.errorMessage(error.localizedDescription)
            self.storeGoals(newGoals)
            return
        }

        guard var currentGoals = currentGoals else {
            self.logManager.errorMessage("currentGoals is nil. Exiting notification.")
            return
        }

        let newGoalsMap = newGoals.reduce(into: [String: ComplicationsUpdateGoalsResponse]()) { $0[$1.id] = $1 }
        let currentGoalsMap = currentGoals.reduce(into: [String: ComplicationsUpdateGoalsResponse]()) { $0[$1.id] = $1 }
        self.logManager.debugMessage("Received the following new goals = \(newGoalsMap)", true)

        for (idx, goal) in currentGoals.enumerated() { // Check if any existing goals require a notification
            if newGoalsMap.contains(where: { $0.key == goal.id }) { // Goal found
                let newGoal = newGoalsMap[goal.id]
                guard let newGoal = newGoal else {
                    self.logManager.errorMessage("newGoal is nil. Moving to next goal.")
                    continue
                }
                self.logManager.debugMessage("oldGoal = \(goal)", true)
                self.logManager.debugMessage("newGoal = \(newGoal)", true)

                if (!goal.isInverse && goal.rangeStatus != "success" && newGoal.rangeStatus == "success") ||
                   (goal.isInverse && goal.rangeStatus != "success" && newGoal.rangeStatus == "fail") {
                    let content = UNMutableNotificationContent()

                    content.title = GoalUtility.getNotificationContentTitle(goal: newGoal)
                    content.body = GoalUtility.getNotificationContentMessage(goal: newGoal)

                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                                    repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                        content: content,
                                                        trigger: trigger)
                    self.logManager.debugMessage("Triggering notification", true)

                    self.center.add(request) { error in
                        if let error = error {
                            self.logManager.reportError(error)
                            return
                        }
                        self.logManager.debugMessage("Notification triggered successfully.")
                        self.analytics.track(event: "Notification Sent for Goal")
                        completionHandler?()
                    }
                }

                currentGoals[idx] = newGoal
            } else { // Goal is no longer valid. User removed it from WakaTime.
                currentGoals.remove(at: idx)
                self.logManager.debugMessage("goal is no longer valid and has been removed", true)
            }
        }

        for newGoal in newGoals { // Store any new goals added.
            if !currentGoalsMap.contains(where: { $0.key == newGoal.id }) {
                self.logManager.debugMessage("Adding new goal to storage", true)
                currentGoals.append(newGoal)
            }
        }

        self.storeGoals(currentGoals)
    }
}
