import Combine
import Foundation
import SwiftUICharts
import SwiftUI

final class SummaryViewModel: ObservableObject {
    @Published var totalDisplayTime = ""
    @Published var loaded = false
    @Published var groupedBarChartData: GroupedBarChartData?
    @Published var editorsPieChartData: PieChartData?
    @Published var languagesPieChartData: PieChartData?

    private var networkService: NetworkService
    private var complicationService: ComplicationService
    private var chartFactory: ChartFactory

    public let telemetry: TelemetryService

    init(networkService: NetworkService,
         complicationService: ComplicationService,
         telemetryService: TelemetryService,
         chartFactory: ChartFactory
        ) {
        self.networkService = networkService
        self.telemetry = telemetryService
        self.complicationService = complicationService
        self.chartFactory = chartFactory
    }

    func getSummary() async {
        let summaryData = await networkService.getSummaryData(.Today)

        let defaults = UserDefaults.standard
        defaults.set(summaryData?.cummulative_total?.seconds,
                     forKey: DefaultsKeys.complicationCurrentTimeCoded)

        self.complicationService.updateTimelines()

        DispatchQueue.main.async {
            self.totalDisplayTime = summaryData?.cummulative_total?.text ?? ""
            self.loaded = true
        }
    }

    func getCharts() async {
        let weeklySummaryData = await networkService.getSummaryData(.Last7Days)
        guard let summaryData = weeklySummaryData?.data?.suffix(5) else {
            return
        }
        self.groupedBarChartData = nil

        DispatchQueue.main.async {
            self.groupedBarChartData = self.chartFactory.makeCodingTimeChart(summaryData: summaryData)
            self.editorsPieChartData = self.chartFactory.makeEditorsChart(summaryData: summaryData)
            self.languagesPieChartData = self.chartFactory.makeLanguagesChart(summaryData: summaryData)
        }
    }
}
