import Foundation

final class ComplicationViewModel: ObservableObject {
    @Published var totalDisplayTime = ""

    func getLocalCurrentTime() {
        let defaults = UserDefaults.standard

        DispatchQueue.main.async {
            self.totalDisplayTime = defaults.string(forKey: DefaultsKeys.complicationCurrentTimeCoded) ?? "00:00"
        }
    }
}
