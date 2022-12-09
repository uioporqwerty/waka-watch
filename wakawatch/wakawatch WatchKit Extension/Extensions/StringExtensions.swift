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
    
    func indexOf(_ of: String.Element) -> Int {
        if let i = self.firstIndex(of: of) {
          return self.distance(from: self.startIndex, to: i)
        }
        
        return -1
    }
    
    func index(from: Int) -> Index {
            return self.index(startIndex, offsetBy: from)
        }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
