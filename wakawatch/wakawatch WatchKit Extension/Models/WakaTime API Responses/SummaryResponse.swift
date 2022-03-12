import Foundation

struct SummaryResponse: Decodable {
    let cummulative_total: CummulativeTotal?
    let data: [SummaryData]?
}

struct CummulativeTotal: Decodable {
    let text: String?
    let seconds: Double?
}

struct SummaryData: Decodable {
    let projects: [SummaryProjectData]?
    let editors: [SummaryEditorData]?
    let languages: [SummaryLanguageData]?
    let range: SummaryRangeData
}

struct SummaryLanguageData: Decodable {
    let name: String?
    let total_seconds: Double?
    let text: String?
}

struct SummaryEditorData: Decodable {
    let name: String?
    let total_seconds: Double?
    let text: String?
}

struct SummaryProjectData: Decodable {
    let total_seconds: Double?
    let name: String?
    let text: String?
}

struct SummaryRangeData: Decodable {
    let date: String?
}
