import Foundation

final class DateUtility {
    static func getDate(date: String, includeTime: Bool = false) -> Date? {
        let dateFormatter = DateFormatter()
        let format = includeTime ? "yyyy-MM-dd'T'HH:mm:ssZ" : "yyyy-MM-dd"
        dateFormatter.dateFormat = format

        return dateFormatter.date(from: date)
    }
}
