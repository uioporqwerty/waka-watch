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

    static func meetsWhatsNewCriteria(currentVersion: String, previousVersion: String) -> Bool {
        guard let currentVersion = Version(currentVersion) else {
            return false
        }

        guard let previousVersion = Version(previousVersion) else {
            return false
        }

        return previousVersion < currentVersion
    }
}
