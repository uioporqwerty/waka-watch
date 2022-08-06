import SwiftUI

struct SummaryView: View {
    @ObservedObject var summaryViewModel: SummaryViewModel
    @State var refreshing = false
    @State var hasError = false

    init(viewModel: SummaryViewModel) {
        self.summaryViewModel = viewModel
    }

    var body: some View {
        VStack {
            if self.hasError {
                ErrorView(logManager: self.summaryViewModel.logManager,
                          description: LocalizedStringKey("SummaryView_Error_Description").toString()
                          ) {
                    try await self.load()
                    self.hasError = false
                }
            } else if self.refreshing || !self.summaryViewModel.loaded {
                ProgressView()
            } else {
                GeometryReader { proxy in
                    RefreshableScrollView(action: {
                        do {
                            try await self.load()
                        } catch {
                            self.hasError = true
                        }
                    }) {
                        VStack {
                            Text(LocalizedStringKey("SummaryView_Today"))

                            Text(summaryViewModel.totalDisplayTime)
                                .multilineTextAlignment(.center)
                                .padding(EdgeInsets(top: 8, leading: 10, bottom: 0, trailing: 10))

                            Divider()
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                            if #available(watchOS 9, *) {
                                SwiftChartsView(summaryData: self.summaryViewModel.summaryData,
                                                size: proxy.size
                                               )
                            } else {
                                SwiftUIChartsView(codingActivityData: self.summaryViewModel.groupedBarChartData,
                                              editorData: self.summaryViewModel.editorsPieChartData,
                                              languagesData: self.summaryViewModel.languagesPieChartData,
                                              goalsData: self.summaryViewModel.goalsChartData,
                                              size: proxy.size
                                             )
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
            self.summaryViewModel.promptPermissions()
            do {
                try await self.load()
            } catch {
                self.summaryViewModel.logManager.reportError(error)
                self.hasError = true
            }
        }
    }

    private func load() async throws {
        try await self.summaryViewModel.getSummary()
        try await self.summaryViewModel.getCharts()
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SummaryView.self)!
    }
}
