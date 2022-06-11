import Foundation

final class LicensesViewModel: ObservableObject {
    @Published var licensesText: String?

    public let logManager: LogManager
    public let telemetry: TelemetryService

    init(logManager: LogManager,
         telemetryService: TelemetryService
        ) {
        self.logManager = logManager
        self.telemetry = telemetryService
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
