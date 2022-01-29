import SwiftUI

struct ProfileView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    init(user: UserData?, loaded: Bool = false) {
        self.profileViewModel = ProfileViewModel()
        self.profileViewModel.getProfile(user: user)
        self.profileViewModel.loaded = loaded
    }
    
    var body: some View {
        if !self.profileViewModel.loaded {
            ProgressView()
        }
        else {
            VStack {
                Text(profileViewModel.displayName)
                
                if (profileViewModel.location != nil) {
                    Text(profileViewModel.location ?? "")
                }
                
                if (profileViewModel.rank != nil) {
                    Text("Rank: \(profileViewModel.rank!)")
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                }
                
                if (profileViewModel.createdDate != nil) {
                    Text("Joined: \(profileViewModel.createdDate!.formatted(date: .abbreviated, time: .omitted))")
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: nil)
    }
}
