import Foundation

final class ComplicationViewModel: ObservableObject {
    func getLocalCurrentTime() -> Double {
        let defaults = UserDefaults.standard
        return defaults.double(forKey: DefaultsKeys.complicationCurrentTimeCoded)
    }
}
