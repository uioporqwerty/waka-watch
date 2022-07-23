import SwiftUICharts
import Foundation
import SwiftUI

final class ChartFactory {
    func makeLanguagesChart(summaryData: ArraySlice<SummaryData>) -> PieChartData {
        var dataPoints: [PieChartDataPoint] = []
        var validColors = Set<Color>([.red, .blue, .green, .orange, .cyan, .indigo])

        var languageUsage: [String: Double] = [:]

        for data in summaryData {
            for language in data.languages ?? [] {
                if !languageUsage.contains(where: { $0.key == language.name! }) {
                    languageUsage[language.name!] = language.total_seconds ?? 0
                } else {
                    languageUsage[language.name!]! += language.total_seconds ?? 0
                }
            }
        }

        for usage in languageUsage {
            // swiftlint:disable line_length
            dataPoints.append(PieChartDataPoint(value: usage.value,
                                                description: "\(usage.key): \(usage.value.toSpelledOutHourMinuteFormat)",
                                                colour: validColors.popFirst() ?? .accentColor,
                                                label: .none))
        }

        return PieChartData(dataSets: PieDataSet(dataPoints: dataPoints,
                                                 legendTitle: LocalizedStringKey("SummaryView_LanguageUsageChart_LegendTitle_Text").toString()),
                            metadata: ChartMetadata(title: LocalizedStringKey("SummaryView_LanguageUsageChart_Title").toString(),
                                                    titleFont: .footnote
                                                   ),
                            chartStyle: PieChartStyle(infoBoxPlacement: .header,
                                                      infoBoxContentAlignment: .horizontal,
                                                      infoBoxValueFont: Font.footnote,
                                                      infoBoxDescriptionFont: Font.footnote
                                                     )
                            )
    }

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
                                                 legendTitle: LocalizedStringKey("SummaryView_EditorUsageChart_LegendTitle_Text").toString()),
                            metadata: ChartMetadata(title: LocalizedStringKey("SummaryView_EditorUsageChart_Title").toString(),
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
                                   metadata: ChartMetadata(title: LocalizedStringKey("SummaryView_CodingTimeChart_Title").toString(),
                                                           titleFont: .footnote),
                                   chartStyle: BarChartStyle(infoBoxPlacement: .header,
                                                            infoBoxContentAlignment: .horizontal,
                                                            infoBoxValueFont: Font.footnote,
                                                            infoBoxDescriptionFont: Font.footnote,
                                                            xAxisLabelFont: Font.footnote,
                                                            xAxisLabelsFrom: .dataPoint(rotation: .degrees(-90))))
    }

    func makeGoalsChart(goalData: GoalData) -> BarChartData {
        var dataPoints: [BarChartDataPoint] = []

        for data in goalData.chart_data.suffix(5) {
            dataPoints.append(BarChartDataPoint(value: data.actual_seconds,
                                                xAxisLabel: DateUtility.getChartDate(date: data.range.date ?? data.range.start),
                                                description: LocalizedStringKey("SummaryView_GoalsChart_Actual_Text").toString(),
                                                date: DateUtility.getDate(date: data.range.date ?? data.range.start),
                                                colour: data.range_status == "success" ? ColourStyle(colour: .green) : ColourStyle(colour: .red)) // TODO: Replace with better colors
                             )
        }

        let data = BarChartData(dataSets: BarDataSet(dataPoints: dataPoints),
                            metadata: ChartMetadata(title: goalData.title,
                                                    titleFont: Font.footnote
                                                    ),
                            barStyle: BarStyle(colourFrom: .dataPoints),
                            chartStyle: BarChartStyle(infoBoxPlacement: .header,
                                                      infoBoxContentAlignment: .horizontal,
                                                      infoBoxValueFont: Font.footnote,
                                                      infoBoxDescriptionFont: Font.footnote,
                                                      xAxisLabelFont: Font.footnote,
                                                      xAxisLabelsFrom: .dataPoint(rotation: .degrees(-90)))
                            )
        data.extraLineData = ExtraLineData(legendTitle: LocalizedStringKey("SummaryView_GoalsChart_Goal_Text").toString(), dataPoints: {
            var points: [ExtraLineDataPoint] = []
            for data in goalData.chart_data {
                points.append(ExtraLineDataPoint(value: data.goal_seconds,
                                    pointColour: PointColour(),
                                                 pointDescription: LocalizedStringKey("SummaryView_GoalsChart_Goal_Text").toString()))
            }
            return points
        }, style: {
            ExtraLineStyle(lineColour: ColourStyle(colour: .gray),
                           lineType: .line,
                           lineSpacing: .line,
                           animationType: .raise,
                           baseline: .zero
                          )
        })

        return data
    }
}
