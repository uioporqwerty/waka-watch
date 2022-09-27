import SwiftUI
import Kingfisher

struct ProfileView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @State var hasError = false
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
            if self.hasError {
                ErrorView(logManager: self.profileViewModel.logManager,
                          description: LocalizedStringKey("ProfileView_Error_Description").toString(),
                          retryButtonAction: {
                            try await self.profileViewModel.getProfile(user: self.user)
                            self.hasError = false
                          })
            } else if !self.profileViewModel.loaded {
                ProgressView()
                    .task {
                        do {
                            try await self.profileViewModel.getProfile(user: self.user)
                            self.hasError = false
                        } catch {
                            self.profileViewModel.logManager.reportError(error)
                            self.hasError = true
                        }
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
                                .accessibilityLabel(Text(LocalizedStringKey("ProfileView_ProfileImage_A11Y")
                                    .toString()
                                    .replaceArgs(self.profileViewModel.displayName)))
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
            self.profileViewModel
                .telemetry
                .recordViewEvent(elementName: "\(String(describing: ProfileView.self))")
            self.profileViewModel
                .analytics
                .track(event: "Profile View Shown")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(ProfileView.self)!
    }
}
