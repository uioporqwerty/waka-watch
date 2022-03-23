import Foundation

struct BackgroundUpdateResponse: Decodable {
    let totalTimeCodedInSeconds: Double
    let goals: [ComplicationsUpdateGoalsResponse]
}

struct ComplicationsUpdateGoalsResponse: Codable {
    let id: String
    let title: String
    let percentCompleted: Double
    let rangeStatusReason: String
    let shortRangeStatusReason: String
    let rangeStatus: String
    let modifedAt: String?
    let isInverse: Bool
    let goalSeconds: Double
    let actualSeconds: Double
}
