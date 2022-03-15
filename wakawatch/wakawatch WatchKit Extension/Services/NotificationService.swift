import UserNotifications
import SwiftUI

final class NotificationService {
    private let center: UNUserNotificationCenter
    private let logManager: LogManager

    init(logManager: LogManager) {
        self.center = UNUserNotificationCenter.current()
        self.logManager = logManager
    }

    func requestAuthorization(authorizedHandler: (() -> Void)? = nil) {
        self.center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                self.logManager.reportError(error)
                return
            }

            if !granted {
                self.logManager.infoMessage("Notification permission not granted.")
                return
            }

            self.logManager.infoMessage("Notification permission granted.")
            authorizedHandler?()
        }
    }

    func isPermissionGranted(onGrantedHandler: (() -> Void)? = nil) {
        self.center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                self.logManager.debugMessage("Notification permission not granted.")
                return
            }
            self.logManager.debugMessage("Notification permission granted.")
            onGrantedHandler?()
        }
    }

    private func storeGoals(_ goals: [ComplicationsUpdateGoalsResponse]) {
        let defaults = UserDefaults.standard

        do {
            try defaults.setObject(goals, forKey: DefaultsKeys.userGoals)
        } catch {
            self.logManager.errorMessage(error.localizedDescription)
        }
    }

    func notifyGoalsAchieved(newGoals: [ComplicationsUpdateGoalsResponse],
                             completionHandler: (() -> Void)? = nil) {
        let defaults = UserDefaults.standard
        var currentGoals: [ComplicationsUpdateGoalsResponse]?
        do {
            currentGoals = try defaults.getObject(forKey: DefaultsKeys.userGoals,
                                                  castTo: Array<ComplicationsUpdateGoalsResponse>.self)
        } catch { // User does not have any stored goals for the first time.
            self.logManager.errorMessage(error.localizedDescription)
            self.storeGoals(newGoals)
            return
        }

        guard var currentGoals = currentGoals else {
            return
        }

        let newGoalsMap = newGoals.reduce(into: [String: ComplicationsUpdateGoalsResponse]()) { $0[$1.id] = $1 }
        let currentGoalsMap = currentGoals.reduce(into: [String: ComplicationsUpdateGoalsResponse]()) { $0[$1.id] = $1 }

        for (idx, goal) in currentGoals.enumerated() { // Check if any existing goals require a notification
            if newGoalsMap.contains(where: { $0.key == goal.id }) {
                let newGoal = newGoalsMap[goal.id]
                guard let newGoal = newGoal else { return }

                if goal.rangeStatus != "success" && newGoal.rangeStatus == "success" {
                    self.logManager.debugMessage("Setting up notification.")
                    let content = UNMutableNotificationContent()
                    content.title = LocalizedStringKey("Notifications_GoalAchieved_Title").toString()
                    content.body = "Congratulations! You've \(goal.rangeStatusReason)" // TODO: i18n

                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                                    repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                        content: content,
                                                        trigger: trigger)
                    self.center.add(request) { error in
                        if let error = error {
                            self.logManager.reportError(error)
                            return
                        }
                        self.logManager.debugMessage("Notification triggered successfully.")
                        completionHandler?()
                    }
                }

                currentGoals[idx] = newGoal
                self.logManager.debugMessage("Updating user goals.")
            }
        }

        for newGoal in newGoals { // Store any new goals added.
            if !currentGoalsMap.contains(where: { $0.key == newGoal.id }) {
                currentGoals.append(newGoal)
            }
        }

        self.storeGoals(currentGoals)
    }
}
