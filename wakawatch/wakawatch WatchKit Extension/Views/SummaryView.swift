import SwiftUI

struct SummaryView: View {
    @ObservedObject var summaryViewModel: SummaryViewModel
    
    init() {
        self.summaryViewModel = SummaryViewModel()
        self.summaryViewModel.getSummary()
    }
    
    var body: some View {
        if !self.summaryViewModel.loaded {
            ProgressView()
        }
        else {
            VStack {
                Text("Today")
                Text(summaryViewModel.totalDisplayTime)
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
