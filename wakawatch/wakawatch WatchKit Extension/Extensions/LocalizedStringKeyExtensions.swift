import SwiftUI

extension LocalizedStringKey {

    /**
     Return localized value of thisLocalizedStringKey
     */
    public func toString() -> String {
        let mirror = Mirror(reflecting: self)

        let attributeLabelAndValue = mirror.children.first { (arg0) -> Bool in
            let (label, _) = arg0

            if label == "key" {
                return true;
            }

            return false;
        }

        if attributeLabelAndValue != nil {
            return String.localizedStringWithFormat(NSLocalizedString(attributeLabelAndValue!.value as? String ?? "", comment: ""));
        } else {
            return "Swift LocalizedStringKey signature must have changed. @see Apple documentation."
        }
    }
}
