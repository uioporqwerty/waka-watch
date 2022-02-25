import Combine
import Foundation
import SwiftUICharts
import SwiftUI

final class SummaryViewModel: ObservableObject {
    @Published var totalDisplayTime = ""
    @Published var loaded = false
    @Published var groupedBarChartData: GroupedBarChartData?

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

    // swiftlint:disable line_length
    func getWeeklySummaryChart() async {
        let weeklySummaryData = await networkService.getSummaryData(.Last7Days)
        guard let summaryData = weeklySummaryData?.data?.suffix(5) else {
            return
        }

        var dataSets: [GroupedBarDataSet] = []
        var dataGroups: [GroupingData] = []

        // TODO: Add A11Y support for colors
        var validColors = Set<Color>([.red, .blue, .green, .orange, .cyan, .indigo])
        var projectColors: [String: Color] = [:]

        for data in summaryData {
            guard let projects = data.projects else {
                continue
            }

            for project in projects {
                if !projectColors.contains(where: { $0.key == project.name! }) {
                    projectColors[project.name!] = validColors.popFirst() ?? .accentColor
                }
            }
        }

        for data in summaryData {
            guard let projects = data.projects else {
                continue
            }

            var dataPoints: [GroupedBarDataPoint] = []

            for project in projects {
                let groupData = GroupingData(title: DateUtility.getChartDate(date: data.range.date!),
                                             colour: ColourStyle(colour: projectColors[project.name!]!))
                dataGroups.append(groupData)
                dataPoints.append(GroupedBarDataPoint(value: project.total_seconds!,
                                                      description: "\(project.name!): \(project.total_seconds!.toHourMinuteFormat)",
                                                      date: DateUtility.getDate(date: data.range.date!),
                                                      group: groupData))
            }
            dataSets.append(GroupedBarDataSet(dataPoints: dataPoints,
                                              setTitle: DateUtility.getChartDate(date: data.range.date!)))
        }

        let data = GroupedBarDataSets(dataSets: dataSets)
        let safeGroups = dataGroups

        DispatchQueue.main.async {
            self.groupedBarChartData = GroupedBarChartData(dataSets: data,
                                                           groups: safeGroups,
                                                           metadata: ChartMetadata(title: "Coding Time Per Day",
                                                                                   titleFont: .footnote),
                                                           chartStyle: BarChartStyle(infoBoxPlacement: .header,
                                                                                    infoBoxContentAlignment: .horizontal,
                                                                                    infoBoxValueFont: Font.footnote,
                                                                                    infoBoxDescriptionFont: Font.footnote,
                                                                                    xAxisLabelFont: Font.footnote,
                                                                                    xAxisLabelsFrom: .dataPoint(rotation: .degrees(-90)))
                                                           )
        }
    }
}
