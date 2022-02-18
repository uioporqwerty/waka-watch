import SwiftUI
import Kingfisher

struct ProfileView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    private let user: UserData?

    init(viewModel: ProfileViewModel, user: UserData?, forceLoad: Bool = false) {
        self.profileViewModel = viewModel
        self.user = user
        if forceLoad {
            self.profileViewModel.loaded = false
        }
    }

    var body: some View {
        VStack {
            if !self.profileViewModel.loaded {
                ProgressView()
                    .task {
                        await self.profileViewModel.getProfile(user: self.user)
                    }
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
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        }

                        Text(profileViewModel.displayName)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))

                        if profileViewModel.location != nil {
                            Text(profileViewModel.location ?? "")
                                .multilineTextAlignment(.center)
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        }

                        if profileViewModel.rank != nil {
                            Text("\("ProfileView_Rank_Text".toLocalized()) \(profileViewModel.rank!)")
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 0, trailing: 10))
                        }

                        if profileViewModel.createdDate != nil {
                            // swiftlint:disable:next line_length
                            Text("\("ProfileView_Joined_Text".toLocalized()) \(profileViewModel.createdDate!.formatted(date: .abbreviated, time: .omitted))")
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 0, trailing: 10))
                        }

                        if profileViewModel.bio != nil {
                            Text(profileViewModel.bio!)
                                .multilineTextAlignment(.leading)
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 0, trailing: 10))
                        }
                    }
                }
            }
        }
        .onAppear {
            self.profileViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: ProfileView.self))")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(ProfileView.self)!
    }
}
