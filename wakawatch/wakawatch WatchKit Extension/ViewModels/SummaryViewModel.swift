import Combine
import Foundation

final class SummaryViewModel: ObservableObject {
    @Published var totalDisplayTime = ""
    @Published var loaded = false

    private var networkService: NetworkService
    private var complicationService: ComplicationService

    public let telemetry: TelemetryService

    init(networkService: NetworkService,
         complicationService: ComplicationService,
         telemetryService: TelemetryService) {
        self.networkService = networkService
        self.telemetry = telemetryService
        self.complicationService = complicationService
    }

    func getSummary() async {
        let summaryData = await networkService.getSummaryData()

        let defaults = UserDefaults.standard
        defaults.set(summaryData?.cummulative_total?.seconds?.toHourMinuteFormat,
                     forKey: DefaultsKeys.complicationCurrentTimeCoded)

        self.complicationService.updateTimelines()

        DispatchQueue.main.async {
            self.totalDisplayTime = summaryData?.cummulative_total?.text ?? ""
            self.loaded = true
        }
    }
}
