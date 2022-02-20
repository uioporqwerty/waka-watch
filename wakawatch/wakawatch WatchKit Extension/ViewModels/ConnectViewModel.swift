import Foundation

final class ConnectViewModel {
    public let telemetry: TelemetryService
    private let networkService: NetworkService

    init(telemetryService: TelemetryService,
         networkService: NetworkService) {
        self.telemetry = telemetryService
        self.networkService = networkService
    }

    func requiresUpdate() async -> Bool {
        #if DEBUG
            return false
        #else
            let appInformation = await self.networkService.getAppInformation()
            let currentAppVersion = Double(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")

            guard let appInformation = appInformation else {
                return false
            }

            return appInformation.minimum_version >= currentAppVersion!
        #endif
    }
}
