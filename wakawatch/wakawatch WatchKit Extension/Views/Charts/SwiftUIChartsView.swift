import SwiftUI
import SwiftUICharts

struct SwiftUIChartsView: View {
    private var codingActivityData: GroupedBarChartData?
    private var editorData: PieChartData?
    private var languagesData: PieChartData?
    private var goalsData: [BarChartData]
    private var size: CGSize

    init(codingActivityData: GroupedBarChartData?,
         editorData: PieChartData?,
         languagesData: PieChartData?,
         goalsData: [BarChartData],
         size: CGSize
        ) {
        self.codingActivityData = codingActivityData
        self.editorData = editorData
        self.languagesData = languagesData
        self.goalsData = goalsData
        self.size = size
    }

    var body: some View {
        VStack {
            if self.codingActivityData == nil {
                ProgressView()
            } else {
                GroupedBarChart(chartData: self.codingActivityData!,
                                groupSpacing: 0)
                .touchOverlay(chartData: self.codingActivityData!)
                .xAxisLabels(chartData: self.codingActivityData!)
                .headerBox(chartData: self.codingActivityData!)
                .frame(height: self.size.height)
            }

            Divider()
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

            if self.editorData == nil {
                ProgressView()
            } else {
                PieChart(chartData: self.editorData!)
                    .touchOverlay(chartData: self.editorData!)
                    .headerBox(chartData: self.editorData!)
                    .frame(height: self.size.height)
            }

            Divider()
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

            if self.languagesData == nil {
                ProgressView()
            } else {
                PieChart(chartData: self.languagesData!)
                    .touchOverlay(chartData: self.languagesData!)
                    .headerBox(chartData: self.languagesData!)
                    .frame(height: self.size.height)
            }

            ForEach(self.goalsData) { chartData in
                Divider()
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                BarChart(chartData: chartData)
                    .touchOverlay(chartData: chartData)
                    .xAxisLabels(chartData: chartData)
                    .extraLine(chartData: chartData,
                               legendTitle: chartData.extraLineData.legendTitle,
                               datapoints: chartData.extraLineData.dataPoints,
                               style: chartData.extraLineData.style)
                    .headerBox(chartData: chartData)
                    .frame(height: self.size.height)
            }
        }
    }
}
