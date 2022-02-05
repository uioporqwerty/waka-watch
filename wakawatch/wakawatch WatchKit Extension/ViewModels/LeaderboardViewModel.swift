import Combine
import Foundation

final class LeaderboardViewModel: ObservableObject {
    @Published var records: [LeaderboardRecord] = []
    @Published var currentUserRecord: LeaderboardRecord?
    @Published var loaded = false

    private var networkService: NetworkService
    public let telemetry: TelemetryService

    init(networkService: NetworkService, telemetryService: TelemetryService) {
        self.networkService = networkService
        self.telemetry = telemetryService
    }

    func getPublicLeaderboard(page: Int?) {
        Task {
            do {
                let leaderboardData = try await networkService.getPublicLeaderboard(page: page)

                DispatchQueue.main.async {

                    var leaderboardRecords: [LeaderboardRecord] = []
                    leaderboardData?.data.forEach { data in
                        guard let user = data.user else {
                            return
                        }

                        leaderboardRecords.append(LeaderboardRecord(id: UUID(uuidString: user.id)!,
                                                                    rank: data.rank,
                                                                    displayName: user.display_name,
                                                                    user: user))
                    }
                    self.records = leaderboardRecords
                    guard let currentUser = leaderboardData?.current_user?.user else {
                        return
                    }
                    self.currentUserRecord = LeaderboardRecord(id: UUID(uuidString: currentUser.id)!,
                                                               rank: leaderboardData?.current_user?.rank,
                                                               displayName: currentUser.display_name,
                                                               user: currentUser)
                    self.loaded = true
                }
            } catch {
                print("Failed to get leaderboard with error: \(error)")
            }
        }
    }
}

struct LeaderboardRecord: Identifiable, Hashable {
    static func == (lhs: LeaderboardRecord, rhs: LeaderboardRecord) -> Bool {
        return lhs.id == rhs.id
    }

    let id: UUID?
    let rank: Int?
    let displayName: String?
    let user: UserData?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
