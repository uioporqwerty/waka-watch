import Foundation

final class ConnectViewModel {
    public let telemetry: TelemetryService
    public let logManager: LogManager
    private let networkService: NetworkService

    init(telemetryService: TelemetryService,
         logManager: LogManager,
         networkService: NetworkService) {
        self.telemetry = telemetryService
        self.logManager = logManager
        self.networkService = networkService
    }

    func requiresUpdate() async -> Bool {
        #if DEBUG
            return false
        #else
            let appInformation = try? await self.networkService.getAppInformation()
            let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

            guard let appInformation = appInformation else {
                return false
            }

            return VersionCheckerUtility.meetsMinimumVersion(currentVersion: currentAppVersion,
                                                             minimumVersion: appInformation.minimum_version)
        #endif
    }
}
