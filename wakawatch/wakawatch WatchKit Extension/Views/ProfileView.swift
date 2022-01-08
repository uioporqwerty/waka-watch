import SwiftUI

struct ProfileView: View {
    var user: User
    
    var body: some View {
        VStack {
            Text(user.displayName)
            
            if (user.location != "") {
                Text(user.location)
            }
            
            Text("Rank: \(user.publicLeaderboardRank)")
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
            
            Text("Joined: \(user.createdDate.formatted(date: .abbreviated, time: .omitted))")
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
            
            if (user.website != nil) {
                Link("Website", destination: user.website!)
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.mockUsers[0])
    }
}
