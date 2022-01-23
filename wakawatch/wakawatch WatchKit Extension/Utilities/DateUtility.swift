import Foundation

final class DateUtility {
    static func getDate(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        return dateFormatter.date(from: date)
    }
}
