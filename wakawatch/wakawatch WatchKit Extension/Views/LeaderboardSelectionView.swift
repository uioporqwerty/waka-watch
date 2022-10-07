import SwiftUI

struct LeaderboardSelectionView: View {
    @ObservedObject private var viewModel: LeaderboardSelectionViewModel
    
    init(viewModel: LeaderboardSelectionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack {
                NavigationLink(LocalizedStringKey("LeaderboardSelectionView_PublicLeaderBoard_Label"),
                               destination: LeaderboardView(
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
                
                if self.viewModel.missingPrivateLeaderboardsScope {
                    Text(LocalizedStringKey("LeaderboardSelectionView_PrivateLeaderboardScopes_Text"))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    
                    AsyncButton(action: {
                        self.viewModel
                            .telemetry
                            .recordViewEvent(elementName: "TAPPED: Disconnect from WakaTime button")
                        try? await self.viewModel.disconnect()
                    }) {
                        Text(LocalizedStringKey("SettingsView_Disconnect_Button"))
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                }
                
                ForEach(self.viewModel.privateLeaderboards) { privateLeaderboard in
                    NavigationLink(privateLeaderboard.name, destination: LeaderboardView(
                        viewModel: privateLeaderboard.viewModel,
                        profileViewModel:
                            DependencyInjection
                            .shared
                            .container
                            .resolve(ProfileViewModel.self)!))
                }
            }.task {
                try? await self.viewModel.loadPrivateLeaderboards()
            }
        }.padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
    }
}

struct LeaderboardSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardSelectionView(viewModel:
                                    DependencyInjection.shared.container.resolve(LeaderboardSelectionViewModel.self)!)
    }
}
