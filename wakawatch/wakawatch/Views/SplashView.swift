import SwiftUI

struct SplashView: View {
    private var splashViewModel: SplashViewModel

    @State var isActive = false
    @State var showActivityIndicator = true

    init(viewModel: SplashViewModel) {
        self.splashViewModel = viewModel
        self.splashViewModel.telemetry.recordViewEvent(elementName: String(describing: SplashView.self))
    }

    var body: some View {
        VStack {
            if self.isActive {
                DependencyInjection.shared.container.resolve(AuthenticationView.self)!
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
                    self.splashViewModel
                        .telemetry
                        .recordNavigationEvent(from: String(describing: SplashView.self),
                                               to: String(describing: AuthenticationView.self))
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(SplashView.self)!
    }
}
