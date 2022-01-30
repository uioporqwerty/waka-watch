import SwiftUI

struct SplashView: View {
    @State var isActive = false
    @State var showActivityIndicator = true
    
    var body: some View {
        VStack {
            if self.isActive {
                AuthenticationView()
            } else {
                Text(LocalizedStringKey("SplashView_Center_Text"))
                    .font(Font.largeTitle)
                ActivityIndicator(shouldAnimate: self.$showActivityIndicator)
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    self.isActive = true
                    self.showActivityIndicator = false
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
