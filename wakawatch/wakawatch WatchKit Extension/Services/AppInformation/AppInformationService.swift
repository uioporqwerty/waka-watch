import Foundation

class AppInformationService {
    func getInstalledAppVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    func getPreviousInstalledAppVersion() -> String? {
        return UserDefaults.standard.string(forKey: DefaultsKeys.previousAppVersion)
    }

    func setPreviousInstalledAppVersion() {
        UserDefaults.standard.set(getInstalledAppVersion(), forKey: DefaultsKeys.previousAppVersion)
    }
}
