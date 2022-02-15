import Foundation

final class DateUtility {
    static func getDate(date: String, includeTime: Bool = false) -> Date? {
        let dateFormatter = DateFormatter()
        let format = includeTime ? "YYYY-MM-DD'T'HH:mm:ssZ" : "YYYY-MM-DD"
        dateFormatter.dateFormat = format

        return dateFormatter.date(from: date)
    }
}
