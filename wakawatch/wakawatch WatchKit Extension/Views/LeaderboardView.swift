import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var leaderboardViewModel: LeaderboardViewModel
    
    init() {
        self.leaderboardViewModel = LeaderboardViewModel()
        self.leaderboardViewModel.getPublicLeaderboard(page: nil)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { value in
                    ForEach (self.leaderboardViewModel.records) { record in
                        NavigationLink(destination: ProfileView(user: record.user)) {
                            Text("\(String(record.rank)). \(record.displayName)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }.id(record.id)
                    }
                    .onAppear {
                        if (self.leaderboardViewModel.currentUserRecord != nil) {
                            value.scrollTo(self.leaderboardViewModel.currentUserRecord!.id, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
