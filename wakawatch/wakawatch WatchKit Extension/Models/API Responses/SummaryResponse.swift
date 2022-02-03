import Foundation

struct SummaryResponse: Decodable {
    let cummulative_total: CummulativeTotal?
}

struct CummulativeTotal: Decodable {
    let text: String?
}
