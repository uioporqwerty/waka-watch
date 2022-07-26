import Foundation

final class InternationalizationService {
    func getUserLanguageCode() -> String? {
        return Bundle.main.preferredLocalizations[0]
    }
}
