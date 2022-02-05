import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var leaderboardViewModel: LeaderboardViewModel

    init(viewModel: LeaderboardViewModel) {
        self.leaderboardViewModel = viewModel
        self.leaderboardViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: LeaderboardView.self))")
        self.leaderboardViewModel.getPublicLeaderboard(page: nil)
    }

    var body: some View {
        if !self.leaderboardViewModel.loaded {
            ProgressView()
        } else {
            // NavigationView { // TODO: Enable navigation view once Apple 8.3+ bug is fixed.
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { value in
                        ForEach(self.leaderboardViewModel.records) { record in
                            // NavigationLink(destination: ProfileView(user: record.user, loaded: true)) {
                            Button(action: { }) {
                                Text("\(String(record.rank ?? 0)). \(record.displayName ?? "")")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }.id(record.id)
                        }
                        .onAppear {
                            if self.leaderboardViewModel.currentUserRecord != nil {
                                value.scrollTo(self.leaderboardViewModel.currentUserRecord!.id, anchor: .center)
                            }
                        }
                    }
               // }
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(LeaderboardView.self)!
    }
}
