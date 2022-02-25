import Foundation

extension TimeInterval {
    var toHourMinuteFormat: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var toSpelledOutHourMinuteFormat: String {
        String(format: "%2d hrs %02d mins", hour, minute)
    }

    var hour: Int {
        Int((self/3600).truncatingRemainder(dividingBy: 3600))
    }

    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
}
