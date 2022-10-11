import Foundation

extension Bundle {
    var currentLocalizedUILanguageCode: String {
        guard let code = Bundle.main.preferredLocalizations.first else {
            return Locale.current.languageCode ?? "en"
        }
        return code
    }
    
}
