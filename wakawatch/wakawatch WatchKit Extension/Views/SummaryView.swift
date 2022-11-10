import SwiftUI

struct SummaryView: View {
    @ObservedObject var viewModel: SummaryViewModel
    @State var refreshing = false
    @State var hasError = false

    init(viewModel: SummaryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if self.hasError {
                ErrorView(logManager: self.viewModel.logManager,
                          description: LocalizedStringKey("SummaryView_Error_Description").toString()
                          ) {
                    try await self.load()
                    self.hasError = false
                }
            } else if self.refreshing || !self.viewModel.loaded {
                ProgressView()
            } else {
                GeometryReader { proxy in
                    RefreshableScrollView(action: {
                        do {
                            try await self.load()
                            self.viewModel
                                .analytics
                                .track(event: "Refreshed Summary View")
                        } catch {
                            self.hasError = true
                        }
                    }) {
                        VStack {
                            if #unavailable(watchOS 9) {
                                if viewModel.totalMeetingTime == nil {
                                    Text("Coding")
                                        .multilineTextAlignment(.center)
                                        .frame(height: 10)
                                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
                                    
                                    Text(viewModel.totalDisplayTime)
                                        .multilineTextAlignment(.center)
                                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
                                    
                                    Divider()
                                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                }
                            }
                            
                            if #available(watchOS 9, *) {
                                SwiftChartsView(summaryData: self.viewModel.summaryData,
                                                todayCodingTime: self.viewModel.totalCodingTime,
                                                todayMeetingTime: self.viewModel.totalMeetingTime,
                                                size: proxy.size
                                               )
                            } else {
                                SwiftUIChartsView(codingActivityData: self.viewModel.groupedBarChartData,
                                              editorData: self.viewModel.editorsPieChartData,
                                              languagesData: self.viewModel.languagesPieChartData,
                                              goalsData: self.viewModel.goalsChartData,
                                              size: proxy.size
                                             )
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            self.viewModel
                .telemetry
                .recordViewEvent(elementName: "\(String(describing: SummaryView.self))")
            self.viewModel
                .analytics
                .track(event: "Summary View Shown")
        }
        .task {
            do {
                try await self.load()
            } catch {
                if error._code != NSURLErrorCancelled {
                    self.viewModel.logManager.reportError(error)
                    self.hasError = true
                }
            }
        }
    }

    private func load() async throws {
        try await self.viewModel.getSummary()
        try await self.viewModel.getCharts()
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SummaryView.self)!
    }
}
