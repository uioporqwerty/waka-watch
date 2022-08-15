import Foundation

struct ExternalDurationResponse: Decodable {
    let data: [ExternalDurationData]
}

struct ExternalDurationData: Decodable {
    let category: String
    let start_time: Double
    let end_time: Double
}
