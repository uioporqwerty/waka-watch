import SwiftUI

struct SummaryView: View {
    @ObservedObject var summaryViewModel: SummaryViewModel
    
    init(viewModel: SummaryViewModel) {
        self.summaryViewModel = viewModel
        self.summaryViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: SummaryView.self))")
        self.summaryViewModel.getSummary()
    }
    
    var body: some View {
        if !self.summaryViewModel.loaded {
            ProgressView()
        }
        else {
            VStack {
                Text(LocalizedStringKey("SummaryView_Today"))
                Text(summaryViewModel.totalDisplayTime)
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SummaryView.self)!
    }
}
