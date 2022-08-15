import Foundation
import SwiftUI

extension TimeInterval {
    var toHourMinuteFormat: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var toSpelledOutHourMinuteFormat: String {
        if self == 0 {
           return "0 secs"
        } else {
           return String(format: "%2d hrs %02d mins", hour, minute)
        }
    }

    var toFullFormat: String {
        LocalizedStringKey("Global_CodingTime_Format")
            .toString()
            .replaceArgs(String(hour), String(minute))
    }

    var hour: Int {
        Int((self/3600).truncatingRemainder(dividingBy: 3600))
    }

    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
}
