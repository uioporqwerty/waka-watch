import SwiftUI

struct ProfileView: View {
    var user: User
    
    var body: some View {
        VStack {
            if (user.photoUrl != nil) {
                AsyncImage(url: user.photoUrl)
            }
            Text(user.displayName)
            Text(user.location)
            Text("Joined: \(user.createdDate)")
            Text("Rank: \(user.publicLeaderboardRank)")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.mockUsers[0])
    }
}
