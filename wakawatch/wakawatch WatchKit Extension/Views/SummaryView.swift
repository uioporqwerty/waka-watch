import SwiftUI

struct SummaryView: View {
    @ObservedObject var summaryViewModel: SummaryViewModel

    init(viewModel: SummaryViewModel) {
        self.summaryViewModel = viewModel
    }

    var body: some View {
        VStack {
            if !self.summaryViewModel.loaded {
                ProgressView()
                    .task {
                        await self.summaryViewModel.getSummary()
                    }
            } else {
                Text(LocalizedStringKey("SummaryView_Today"))
                Text(summaryViewModel.totalDisplayTime)
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
            }
        }.onAppear {
            self.summaryViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: SummaryView.self))")
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SummaryView.self)!
    }
}
