import Foundation
import SwiftUI

final class GoalUtility {
    static func getNotificationContentTitle(goal: ComplicationsUpdateGoalsResponse) -> String {
        return goal.isInverse ?
        LocalizedStringKey("Notifications_InverseGoalFailed_Title").toString() :
        LocalizedStringKey("Notifications_GoalAchieved_Title").toString()
    }

    static func getNotificationContentMessage(goal: ComplicationsUpdateGoalsResponse) -> String {
        let contentMessageTemplate = goal.isInverse ?
        LocalizedStringKey("Notifications_InverseGoalFailed_Message").toString() :
        LocalizedStringKey("Notifications_GoalAchieved_Message").toString()

        let hoursDifference = (goal.actualSeconds - goal.goalSeconds).hour
        let minutesDifference = (goal.actualSeconds - goal.goalSeconds).minute

        return contentMessageTemplate.replaceArgs(
                      String(goal.actualSeconds.hour),
                      String(goal.actualSeconds.minute),
                      String(hoursDifference),
                      String(minutesDifference)
                     )
    }
}
