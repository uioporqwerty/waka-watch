import Foundation

final class SplashViewModel {
    public let telemetry: TelemetryService
    public let analytics: AnalyticsService

    init(telemetryService: TelemetryService,
         analyticsService: AnalyticsService
        ) {
        self.telemetry = telemetryService
        self.analytics = analyticsService
    }
}
