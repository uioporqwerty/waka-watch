import Foundation

final class WhatsNewViewModel: ObservableObject {
    @Published var show = false
    @Published var text: String?

    public let telemetry: TelemetryService
    private let networkService: NetworkService
    private let i18nService: InternationalizationService
    private let appInformationService: AppInformationService

    init(telemetryService: TelemetryService,
         networkService: NetworkService,
         i18nService: InternationalizationService,
         appInformationService: AppInformationService) {
        self.telemetry = telemetryService
        self.networkService = networkService
        self.i18nService = i18nService
        self.appInformationService = appInformationService
    }

    func showWhatsNew() {
        guard let previousVersion = self.appInformationService.getPreviousInstalledAppVersion(),
              let currentVersion = self.appInformationService.getInstalledAppVersion() else {
            self.appInformationService.setPreviousInstalledAppVersion()
            return
        }

        if VersionCheckerUtility.meetsWhatsNewCriteria(currentVersion: currentVersion,
                                                       previousVersion: previousVersion) {
            DispatchQueue.main.async {
                self.show = true
            }
        }
    }

    func loadWhatsNew() throws {
        let url = Bundle.main.url(forResource: "WhatsNew", withExtension: "txt")!
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.plain]
        let whatsNewText = try NSAttributedString(url: url, options: options, documentAttributes: nil).string

        DispatchQueue.main.async {
            self.text = whatsNewText
        }
    }

    func dismiss() {
        self.appInformationService.setPreviousInstalledAppVersion()
        DispatchQueue.main.async {
            self.show = false
        }
    }
}
