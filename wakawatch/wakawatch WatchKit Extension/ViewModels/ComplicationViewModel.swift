import Foundation

final class ComplicationViewModel: ObservableObject {
    func getLocalCurrentTime() -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: DefaultsKeys.complicationCurrentTimeCoded) ?? "00:00"
    }
}
