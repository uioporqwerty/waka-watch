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
    @Published var goalsChartData: [BarChartData] = []

    public var logManager: LogManager
    private var networkService: NetworkService
    private var complicationService: ComplicationService
    private let notificationService: NotificationService
    private var chartFactory: ChartFactory

    public let telemetry: TelemetryService

    init(networkService: NetworkService,
         complicationService: ComplicationService,
         telemetryService: TelemetryService,
         notificationService: NotificationService,
         chartFactory: ChartFactory,
         logManager: LogManager
        ) {
        self.networkService = networkService
        self.telemetry = telemetryService
        self.complicationService = complicationService
        self.notificationService = notificationService
        self.chartFactory = chartFactory
        self.logManager = logManager
    }

    func getSummary() async throws {
        let summaryData = try await networkService.getSummaryData(.Today)

        let defaults = UserDefaults.standard
        defaults.set(summaryData?.cummulative_total?.seconds,
                     forKey: DefaultsKeys.complicationCurrentTimeCoded)

        self.complicationService.updateTimelines()

        DispatchQueue.main.async {
            self.totalDisplayTime = summaryData?.cummulative_total?.text ?? ""
            self.loaded = true
        }
    }

    func getCharts() async throws {
        let weeklySummaryData = try await networkService.getSummaryData(.Last7Days)
        let goalsData = try await networkService.getGoalsData()
        guard let summaryData = weeklySummaryData?.data?.suffix(5) else {
            return
        }

        guard let goalsData = goalsData?.data else {
            return
        }

        // TODO: Likely don't need this block below
        self.groupedBarChartData = nil
        self.goalsChartData = []
        self.editorsPieChartData = nil
        self.languagesPieChartData = nil

        DispatchQueue.main.async {
            self.groupedBarChartData = self.chartFactory.makeCodingTimeChart(summaryData: summaryData)
            self.editorsPieChartData = self.chartFactory.makeEditorsChart(summaryData: summaryData)
            self.languagesPieChartData = self.chartFactory.makeLanguagesChart(summaryData: summaryData)
            for goal in goalsData {
                self.goalsChartData.append(self.chartFactory.makeGoalsChart(goalData: goal))
            }
        }
    }

    func promptPermissions() {
        self.notificationService.requestAuthorization()
    }
}
