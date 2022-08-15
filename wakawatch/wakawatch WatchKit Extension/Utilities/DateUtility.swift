import Foundation

final class DateUtility {
    static func getDate(date: String, includeTime: Bool = false) -> Date? {
        let dateFormatter = DateFormatter()
        let format = includeTime ? "yyyy-MM-dd'T'HH:mm:ssZ" : "yyyy-MM-dd"
        dateFormatter.dateFormat = format

        return dateFormatter.date(from: date)
    }

    static func getChartDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        let inputFormat = "yyyy-MM-dd"
        dateFormatter.dateFormat = inputFormat
        let inputDate = dateFormatter.date(from: date)

        let outputFormat = "MMM. d"
        dateFormatter.dateFormat = outputFormat
        return dateFormatter.string(from: inputDate!)
    }

    static func getFormattedCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}
