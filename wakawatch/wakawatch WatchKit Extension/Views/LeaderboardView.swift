import SwiftUI
import Kingfisher

struct LeaderboardRecordView: View {
    private let record: LeaderboardRecord
    private let isCurrentUser: Bool

    init(_ record: LeaderboardRecord, isCurrentUser: Bool) {
        self.record = record
        self.isCurrentUser = isCurrentUser
    }

    var body: some View {
        LazyVStack {
            Button(action: { }) {
                HStack {
                    KFImage(URL(string: "\(record.user!.photo!)?s=420")!)
                        .placeholder {
                            ProgressView().progressViewStyle(.circular)
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
            }.if(self.isCurrentUser) {
                $0.background(Color.accentColor)
            }
        }
    }
}

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
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack {
                        ForEach(self.leaderboardViewModel.records) { record in
                            LeaderboardRecordView(record,
                                                  isCurrentUser:
                                                    record.id ==
                                                    self.leaderboardViewModel.currentUserRecord?.id)
                                .id(record.id)
                                .onAppear {
                                    self.onLeaderboardRecordAppear(record)
                                }
                        }
                    }
                }.onAppear {
                    if self.leaderboardViewModel.currentUserRecord != nil {
                        proxy.scrollTo(self.leaderboardViewModel.currentUserRecord!.id, anchor: .center)
                    }
                }
            }
        }
    }

    private func onLeaderboardRecordAppear(_ record: LeaderboardRecord) {
        if self.leaderboardViewModel.isFirstLeaderboardRecord(record) {
            self.leaderboardViewModel.loadPreviousPage()
        } else if self.leaderboardViewModel.isLastLeaderboardRecord(record) {
            self.leaderboardViewModel.loadNextPage()
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        DependencyInjection.shared.container.resolve(LeaderboardView.self)!
    }
}
