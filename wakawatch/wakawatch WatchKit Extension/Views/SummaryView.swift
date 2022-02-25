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
                    ScrollView(.vertical) {
                        ZStack {
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
                                        .headerBox(chartData: self.summaryViewModel.groupedBarChartData!)
                                        .touchOverlay(chartData: self.summaryViewModel.groupedBarChartData!)
                                        .xAxisLabels(chartData: self.summaryViewModel.groupedBarChartData!)
                                        .frame(height: proxy.size.height)
                                }
                            }

                            VStack {
                                AsyncButton(action: {
                                    self.refreshing = true
                                    await self.summaryViewModel.getSummary()
                                    await self.summaryViewModel.getWeeklySummaryChart()
                                    self.refreshing = false
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .padding()
                                        .background(Color.accentColor)
                                        .frame(width: 28, height: 28)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        }
                    }
                }
            }
        }
        .onAppear {
            self.summaryViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: SummaryView.self))")
        }
        .task {
            await self.summaryViewModel.getSummary()
            await self.summaryViewModel.getWeeklySummaryChart()
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SummaryView.self)!
    }
}
