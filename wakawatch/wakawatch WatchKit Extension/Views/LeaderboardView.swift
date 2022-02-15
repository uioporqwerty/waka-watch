import SwiftUI

struct LeaderboardRecordView: View {
    private let record: LeaderboardRecord

    init(_ record: LeaderboardRecord) {
        self.record = record
    }

    var body: some View {
        LazyVStack {
            Button(action: { }) {
                HStack {
                    AsyncImage(url: URL(string: "\(record.user!.photo!)?s=420")) { image in
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                             .clipShape(Circle())
                    } placeholder: {
                        ProgressView().progressViewStyle(.circular)
                    }.frame(width: 16, height: 16)
                    Text("\(String(record.rank ?? 0)). \(record.displayName ?? "")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
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
                            LeaderboardRecordView(record)
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
