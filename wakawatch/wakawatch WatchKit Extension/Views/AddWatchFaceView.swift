import SwiftUI

struct AddWatchFaceView: View {
    @ObservedObject var viewModel: AddWatchFaceViewModel
    @Environment(\.colorScheme) var colorScheme
    
    init(viewModel: AddWatchFaceViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack() {
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 140, height: 140)
                        .scaledToFit()
                        
                    
                    Image("Modular")
                        .resizable()
                        .frame(width: 260, height: 260)
                        .layoutPriority(-1)
                }.clipped()
                
                Image(self.colorScheme == .light ? "Add Apple Watch Face - Light" : "Add Apple Watch Face - Dark")
                    .resizable()
                    .scaledToFit()
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    .onTapGesture {
                        self.viewModel.addWatchFace(name: "Modular")
                    }
            }
            .onAppear {
                self.viewModel
                    .telemetry
                    .recordViewEvent(elementName: "\(String(describing: AddWatchFaceView.self))")
                self.viewModel.analytics.track(event: "Add Watch Face View")
            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
    }
}

struct AddWatchFace_Previews: PreviewProvider {
    static var previews: some View {
        AddWatchFaceView(viewModel: DependencyInjection.shared.container.resolve(AddWatchFaceViewModel.self)!)
    }
}
