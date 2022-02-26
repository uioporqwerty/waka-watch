import SwiftUI
import SwiftUICharts

struct SummaryView: View {
    @ObservedObject var summaryViewModel: SummaryViewModel
    @State var refreshing = false

    init(viewModel: SummaryViewModel) {
        self.summaryViewModel = viewModel
    }

    var body: some View {
        VStack {
            if self.refreshing || !self.summaryViewModel.loaded {
                ProgressView()
            } else {
                GeometryReader { proxy in
                    RefreshableScrollView(action: {
                        await self.load()
                    }) {
                        VStack {
                            Text(LocalizedStringKey("SummaryView_Today"))

                            Text(summaryViewModel.totalDisplayTime)
                                .multilineTextAlignment(.center)
                                .padding(EdgeInsets(top: 8, leading: 10, bottom: 0, trailing: 10))

                            Divider()
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                            if self.summaryViewModel.groupedBarChartData == nil {
                              ProgressView()
                            } else {
                                GroupedBarChart(chartData: self.summaryViewModel.groupedBarChartData!,
                                                groupSpacing: 0)
                                    .touchOverlay(chartData: self.summaryViewModel.groupedBarChartData!)
                                    .xAxisLabels(chartData: self.summaryViewModel.groupedBarChartData!)
                                    .headerBox(chartData: self.summaryViewModel.groupedBarChartData!)
                                    .frame(height: proxy.size.height)
                            }

                            Divider()
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                            if self.summaryViewModel.editorsPieChartData == nil {
                              ProgressView()
                            } else {
                                PieChart(chartData: self.summaryViewModel.editorsPieChartData!)
                                        .touchOverlay(chartData: self.summaryViewModel.editorsPieChartData!)
                                        .headerBox(chartData: self.summaryViewModel.editorsPieChartData!)
                                        .frame(height: proxy.size.height)
                            }

                            Divider()
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                            if self.summaryViewModel.languagesPieChartData == nil {
                              ProgressView()
                            } else {
                                PieChart(chartData: self.summaryViewModel.languagesPieChartData!)
                                        .touchOverlay(chartData: self.summaryViewModel.languagesPieChartData!)
                                        .headerBox(chartData: self.summaryViewModel.languagesPieChartData!)
                                        .frame(height: proxy.size.height)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            self.summaryViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: SummaryView.self))")
        }
        .task {
            await self.load()
        }
    }
    
    private func load() async {
        await self.summaryViewModel.getSummary()
        await self.summaryViewModel.getCharts()
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SummaryView.self)!
    }
}
