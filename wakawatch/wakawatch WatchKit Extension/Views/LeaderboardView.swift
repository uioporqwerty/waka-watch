import SwiftUI

struct LeaderboardView: View {
//    var leaderboardRecords: [LeaderboardRecord]
//    @State var selectedRecord: LeaderboardRecord? = nil
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
//                    ForEach (leaderboardRecords) { leaderboardRecord in
//                        NavigationLink(destination: ProfileView(user: leaderboardRecord.user, rank: leaderboardRecord.rank)) {
//                            Text("\(leaderboardRecord.rank).\(leaderboardRecord.user.displayName)")
//                        }
//                    }
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
