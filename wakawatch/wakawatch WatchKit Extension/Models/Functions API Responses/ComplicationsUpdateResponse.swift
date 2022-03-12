import Foundation

struct ComplicationsUpdateResponse: Decodable {
    let totalTimeCodedInSeconds: Double
    let goals: [ComplicationsUpdateGoalsResponse]
}

struct ComplicationsUpdateGoalsResponse: Decodable {
    let title: String
    let percentCompleted: Double
}
