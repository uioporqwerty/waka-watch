import Foundation

final class SplashViewModel {
    public let telemetry: TelemetryService
    
    init(telemetryService: TelemetryService) {
        self.telemetry = telemetryService
    }
}
