import CoreFoundation

enum WakaTimeError: Error {
    case unauthorized
    case unsetTimezone
    case missingScopes
    case unknown
}
