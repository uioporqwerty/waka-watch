import SwiftVersionCompare

final class VersionCheckerUtility {
    static func meetsMinimumVersion(currentVersion: String, minimumVersion: String) -> Bool {
        guard let currentVersion = Version(currentVersion) else {
            return false
        }

        guard let minimumVersion = Version(minimumVersion) else {
            return false
        }

        return currentVersion < minimumVersion
    }
}
