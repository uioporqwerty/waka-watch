import SwiftUI

struct LeaderboardSelectionView: View {
    var body: some View {
        ScrollView {
            VStack {
                NavigationLink(LocalizedStringKey("LeaderboardSelectionView_PublicLeaderBoard_Label"),
                               destination: PublicLeaderboardView(
                                                viewModel:
                                                    DependencyInjection
                                                        .shared
                                                        .container
                                                        .resolve(LeaderboardViewModel.self)!,
                                                profileViewModel:
                                                    DependencyInjection
                                                    .shared
                                                    .container
                                                    .resolve(ProfileViewModel.self)!
                               )).padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
        }
    }
}

struct LeaderboardSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardSelectionView()
    }
}
