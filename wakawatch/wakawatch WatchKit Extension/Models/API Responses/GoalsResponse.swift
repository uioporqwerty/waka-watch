import Foundation

struct GoalsResponse: Decodable {
    let data: [GoalData]
}

struct GoalData: Decodable {
    let id: String
    let chart_data: [GoalChartData]
    let is_enabled: Bool
    let is_snoozed: Bool
    let title: String
    let created_at: String
}

struct GoalChartData: Decodable {
    let actual_seconds: Double
    let goal_seconds: Double
}
