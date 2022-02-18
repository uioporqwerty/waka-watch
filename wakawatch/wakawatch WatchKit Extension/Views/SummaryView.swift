import SwiftUI

struct SummaryView: View {
    @ObservedObject var summaryViewModel: SummaryViewModel
    @State var refreshing = false

    init(viewModel: SummaryViewModel) {
        self.summaryViewModel = viewModel
    }

    var body: some View {
        ZStack {
            if self.refreshing || !self.summaryViewModel.loaded {
                ProgressView()
            } else {
                HStack {
                    AsyncButton(action: {
                        self.refreshing = true
                        await self.summaryViewModel.getSummary()
                        self.refreshing = false
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .clipShape(Circle())
                    .frame(width: 32, height: 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))

                VStack {
                    Text(LocalizedStringKey("SummaryView_Today"))

                    Text(summaryViewModel.totalDisplayTime)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 16, leading: 10, bottom: 0, trailing: 10))
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.onAppear {
            self.summaryViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: SummaryView.self))")
        }
        .task {
            await self.summaryViewModel.getSummary()
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SummaryView.self)!
    }
}
