import Foundation
import SwiftUI

extension TimeInterval {
    var toHourMinuteFormat: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var toSpelledOutHourMinuteFormat: String {
        if self == 0 {
            return LocalizedStringKey("Global_CodingTimeNone_A11Y").toString().replaceArgs(String(0))
        } else {
            return LocalizedStringKey("Global_CodingTimeFull_A11Y").toString().replaceArgs(String(hour), String(minute))
        }
    }

    var toFullFormat: String {
        LocalizedStringKey("Global_CodingTime_Format")
            .toString()
            .replaceArgs(String(hour), String(minute))
    }

    var hour: Int {
        Int(self / 3600)
    }

    var minute: Int {
        Int(self / 60)
    }
}
