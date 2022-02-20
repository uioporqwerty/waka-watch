import SwiftUI
import Kingfisher

struct LeaderboardRecordView: View {
    private let record: LeaderboardRecord

    init(_ record: LeaderboardRecord) {
        self.record = record
    }

    var body: some View {
        HStack {
            KFImage(URL(string: "\(record.user!.photo!)?s=420")!)
                .placeholder {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 16, height: 16)
                }
                .cancelOnDisappear(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 16, height: 16)
            Text("\(String(record.rank ?? 0)). \(record.displayName ?? "")")
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
}

struct LeaderboardView: View {
    @ObservedObject var leaderboardViewModel: LeaderboardViewModel
    @State var loadingData = false
    private let profileViewModel: ProfileViewModel

    init(viewModel: LeaderboardViewModel, profileViewModel: ProfileViewModel) {
        self.leaderboardViewModel = viewModel
        self.profileViewModel = profileViewModel
        self.leaderboardViewModel.telemetry.recordViewEvent(elementName: "\(String(describing: LeaderboardView.self))")
    }

    var body: some View {
        if !self.leaderboardViewModel.loaded {
            ProgressView().task {
                await self.leaderboardViewModel.getPublicLeaderboard(page: nil)
            }
        } else {
            ScrollViewReader { proxy in
                ZStack {
                    ScrollView(.vertical) {
                        LazyVStack {
                            if self.leaderboardViewModel.previousPage ?? 0 > 0 {
                                AsyncButton(action: {
                                    self.loadingData = true
                                    await self.leaderboardViewModel.loadPreviousPage()
                                }) {
                                    Text(LocalizedStringKey("LeaderboardView_Load_Previous_Button"))
                                }
                            }
                            ForEach(self.leaderboardViewModel.records) { record in
                                NavigationLink(destination: ProfileView(viewModel:
                                                                        DependencyInjection
                                                                            .shared
                                                                            .container
                                                                            .resolve(ProfileViewModel.self)!,
                                                                        user: record.user,
                                                                        forceLoad: true)) {
                                        LeaderboardRecordView(record)
                                        .id(record.id)
                                }.if(record.id == self.leaderboardViewModel.currentUserRecord?.id) {
                                    $0.background(Color.accentColor)
                                }
                            }
                            if self.leaderboardViewModel.nextPage ?? self.leaderboardViewModel.totalPages
                                < self.leaderboardViewModel.totalPages {
                                AsyncButton(action: {
                                    self.loadingData = true
                                    await self.leaderboardViewModel.loadNextPage()
                                }) {
                                    Text(LocalizedStringKey("LeaderboardView_Load_Next_Button"))
                                }
                            }
                        }
                    }
                    .onReceive(self.leaderboardViewModel.$records) { _ in
                        if self.leaderboardViewModel.currentUserRecord != nil && !self.loadingData {
                            proxy.scrollTo(self.leaderboardViewModel.currentUserRecord!.id, anchor: .center)
                        }
                    }

                    VStack {
                        FloatingMenu(menuItem1Action: {
                            proxy.scrollTo(self.leaderboardViewModel.currentUserRecord!.id, anchor: .center)
                        })
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(LeaderboardView.self)!
    }
}
