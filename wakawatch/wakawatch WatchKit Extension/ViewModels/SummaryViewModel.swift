import Combine
import Foundation
import SwiftUICharts
import SwiftUI

final class SummaryViewModel: ObservableObject {
    @Published var totalDisplayTime = ""
    @Published var totalMeetingTime: Double?
    @Published var totalCodingTime: Double = 0.0
    @Published var loaded = false
    @Published var groupedBarChartData: GroupedBarChartData?
    @Published var editorsPieChartData: PieChartData?
    @Published var languagesPieChartData: PieChartData?
    @Published var goalsChartData: [BarChartData] = []
    @Published var summaryData: [SummaryData]?

    public var logManager: LogManager
    private var networkService: NetworkService
    private var complicationService: ComplicationService
    private var chartFactory: ChartFactory

    public let telemetry: TelemetryService

    init(networkService: NetworkService,
         complicationService: ComplicationService,
         telemetryService: TelemetryService,
         chartFactory: ChartFactory,
         logManager: LogManager
        ) {
        self.networkService = networkService
        self.telemetry = telemetryService
        self.complicationService = complicationService
        self.chartFactory = chartFactory
        self.logManager = logManager
    }

    func getSummary() async throws {
        let summaryData = try await networkService.getSummaryData(.Today)
        var totalMeetingTime = 0.0
        var totalCodingTime = 0.0
        let categories = summaryData?.data?.first?.categories ?? []
        
        for category in categories {
            if category.name == "Coding" {
                totalCodingTime += category.total_seconds
            } else if category.name == "Meeting" {
                totalMeetingTime += category.total_seconds
            }
        }
        
        let finalMeetingTime = totalMeetingTime
        let finalCodingTime = totalCodingTime
        
        let defaults = UserDefaults.standard
        defaults.set(finalCodingTime,
                     forKey: DefaultsKeys.complicationCurrentTimeCoded)

        self.complicationService.updateTimelines()
        
        DispatchQueue.main.async {
            self.totalDisplayTime = finalCodingTime.toSpelledOutHourMinuteFormat
            self.totalCodingTime = finalCodingTime
            self.totalMeetingTime = finalMeetingTime
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
            self.summaryData = Array(summaryData)
            self.groupedBarChartData = self.chartFactory.makeCodingTimeChart(summaryData: summaryData)
            self.editorsPieChartData = self.chartFactory.makeEditorsChart(summaryData: summaryData)
            self.languagesPieChartData = self.chartFactory.makeLanguagesChart(summaryData: summaryData)
            for goal in goalsData {
                self.goalsChartData.append(self.chartFactory.makeGoalsChart(goalData: goal))
            }
        }
    }
}
