import SwiftUI
import Foundation

extension String {
    func toLocalized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }

    func replaceArgs(_ args: String...) -> String {
        var result = self

        for i in 0...args.count - 1 {
            let regex = "\\{" + String(i) + "\\}"
            result = result.replacingOccurrences(of: regex, with: args[i], options: [.regularExpression])
        }

        return result
    }

    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func toWakaTimeError() -> WakaTimeError {
        if self.starts(with: "This resource requires scopes") {
            return .missingScopes
        }
        
        switch self {
        case "Unauthorized":
            return .unauthorized
        case "User is missing a timezone.", "Set a timezone in your account settings.":
            return .unsetTimezone
        default:
            return .unknown
        }
    }
}
