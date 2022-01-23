import Combine
import Foundation

final class LeaderboardViewModel: NSObject, ObservableObject {
    @Published var records: [LeaderboardRecord] = []
    @Published var currentUserRecord: LeaderboardRecord?
    
    private var networkService: NetworkService
    
    override init() {
        self.networkService = NetworkService()
    }
    
    func getPublicLeaderboard(page: Int?) {
        Task {
            do {
                let leaderboardData = try await networkService.getPublicLeaderboard(page: page)
                
                DispatchQueue.main.async {
                    
                    var leaderboardRecords: [LeaderboardRecord] = []
                    leaderboardData.data.forEach { data in
                        leaderboardRecords.append(LeaderboardRecord(id: UUID(uuidString: data.user.id)!, rank: data.rank, displayName: data.user.display_name, user: data.user))
                    }
                    self.records = leaderboardRecords
                    self.currentUserRecord = LeaderboardRecord(id: UUID(uuidString: leaderboardData.current_user.user.id)!, rank: leaderboardData.current_user.rank, displayName: leaderboardData.current_user.user.display_name, user: leaderboardData.current_user.user)
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
    
    let id: UUID
    let rank: Int
    let displayName: String
    let user: UserData
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
