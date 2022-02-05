import Foundation

final class ConnectViewModel {
    public let telemetry: TelemetryService

    init(telemetryService: TelemetryService) {
        self.telemetry = telemetryService
    }
}
