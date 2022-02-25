import SwiftUICharts
import Foundation
import SwiftUI

final class ChartFactory {
    func makeEditorsChart(summaryData: ArraySlice<SummaryData>) -> PieChartData {
        var dataPoints: [PieChartDataPoint] = []
        var validColors = Set<Color>([.red, .blue, .green, .orange, .cyan, .indigo])

        var editorUsage: [String: Double] = [:]

        for data in summaryData {
            for editor in data.editors ?? [] {
                if !editorUsage.contains(where: { $0.key == editor.name! }) {
                    editorUsage[editor.name!] = editor.total_seconds ?? 0
                } else {
                    editorUsage[editor.name!]! += editor.total_seconds ?? 0
                }
            }
        }

        for usage in editorUsage {
            // swiftlint:disable line_length
            dataPoints.append(PieChartDataPoint(value: usage.value,
                                                description: "\(usage.key): \(usage.value.toSpelledOutHourMinuteFormat)",
                                                colour: validColors.popFirst() ?? .accentColor,
                                                label: .none))
        }

        return PieChartData(dataSets: PieDataSet(dataPoints: dataPoints,
                                                 legendTitle: "Editors"),
                            metadata: ChartMetadata(title: "5 Day Editor Usage",
                                                    titleFont: .footnote
                                                   ),
                            chartStyle: PieChartStyle(infoBoxPlacement: .header,
                                                      infoBoxContentAlignment: .horizontal,
                                                      infoBoxValueFont: Font.footnote,
                                                      infoBoxDescriptionFont: Font.footnote
                                                     )
                            )
    }

    func makeCodingTimeChart(summaryData: ArraySlice<SummaryData>) -> GroupedBarChartData {
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
                // swiftlint:disable line_length
                dataPoints.append(GroupedBarDataPoint(value: project.total_seconds!,
                                                      description: "\(project.name!): \(project.total_seconds!.toHourMinuteFormat)",
                                                      date: DateUtility.getDate(date: data.range.date!),
                                                      group: groupData))
            }
            dataSets.append(GroupedBarDataSet(dataPoints: dataPoints,
                                              setTitle: DateUtility.getChartDate(date: data.range.date!)))
        }

        return GroupedBarChartData(dataSets: GroupedBarDataSets(dataSets: dataSets),
                                   groups: dataGroups,
                                   metadata: ChartMetadata(title: "Coding Time Per Day",
                                                           titleFont: .footnote),
                                   chartStyle: BarChartStyle(infoBoxPlacement: .header,
                                                            infoBoxContentAlignment: .horizontal,
                                                            infoBoxValueFont: Font.footnote,
                                                            infoBoxDescriptionFont: Font.footnote,
                                                            xAxisLabelFont: Font.footnote,
                                                            xAxisLabelsFrom: .dataPoint(rotation: .degrees(-90))))
    }
}
