import SwiftUI

extension String {
    func toLocalized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }
}
