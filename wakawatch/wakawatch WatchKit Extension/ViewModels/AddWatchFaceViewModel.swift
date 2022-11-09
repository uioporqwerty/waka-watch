import Foundation
import ClockKit

final class AddWatchFaceViewModel: ObservableObject {
    @Published var loading = false
    
    public let telemetry: TelemetryService
    public let analytics: AnalyticsService
    private let logManager: LogManager
    
    init(telemetryService: TelemetryService,
         logManager: LogManager,
         analytics: AnalyticsService) {
        self.telemetry = telemetryService
        self.logManager = logManager
        self.analytics = analytics
    }

    func addWatchFace(name: String) {
        if let watchFaceUrl = Bundle.main.url(forResource: name, withExtension: ".watchface") {
            CLKWatchFaceLibrary().addWatchFace(at: watchFaceUrl) { error in
                if let error = error {
                    self.logManager.reportError(error)
                    return
                }
                
                self.analytics.track(event: "Watch Face Added")
            }
        }
    }
}
