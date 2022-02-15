import SwiftUI
import Kingfisher

struct ProfileView: View {
    @ObservedObject var profileViewModel: ProfileViewModel

    init(viewModel: ProfileViewModel, user: UserData?, loaded: Bool = false) {
        self.profileViewModel = viewModel
        self.profileViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: ProfileView.self))")
        self.profileViewModel.getProfile(user: user)
        self.profileViewModel.loaded = loaded
    }

    var body: some View {
        if !self.profileViewModel.loaded {
            ProgressView()
        } else {
            ScrollView {
                VStack {
                    if profileViewModel.photoUrl != nil {
                        KFImage(URL(string: "\(profileViewModel.photoUrl!)?s=420")!)
                            .placeholder {
                                ProgressView().progressViewStyle(.circular)
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: 100, height: 100)
                    }

                    Text(profileViewModel.displayName)

                    if profileViewModel.location != nil {
                        Text(profileViewModel.location ?? "")
                    }

                    if profileViewModel.rank != nil {
                        Text("\("ProfileView_Rank_Text".toLocalized()) \(profileViewModel.rank!)")
                            .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                    }

                    if profileViewModel.createdDate != nil {
                        // swiftlint:disable:next line_length
                        Text("\("ProfileView_Joined_Text".toLocalized()) \(profileViewModel.createdDate!.formatted(date: .abbreviated, time: .omitted))")
                            .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(ProfileView.self)!
    }
}
