import SwiftUI

struct SummaryView: View {
    var totalDisplayTime: String
    
    var body: some View {
        VStack {
            Text("Today")
            Text(totalDisplayTime)
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView(totalDisplayTime: "4 mins")
    }
}
