import Foundation

final class LicensesViewModel: ObservableObject {
    @Published var licensesText: String?

    public let logManager: LogManager
    public let telemetry: TelemetryService
    public let analytics: AnalyticsService
    
    init(logManager: LogManager,
         telemetryService: TelemetryService,
         analytics: AnalyticsService
        ) {
        self.logManager = logManager
        self.telemetry = telemetryService
        self.analytics = analytics
    }

    func loadLicensesFile() throws {
        let url = Bundle.main.url(forResource: "Licenses", withExtension: "rtf")!
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf]
        let licenseFile = try NSAttributedString(url: url, options: options, documentAttributes: nil).string

        DispatchQueue.main.async {
            self.licensesText = licenseFile
        }
    }
}
