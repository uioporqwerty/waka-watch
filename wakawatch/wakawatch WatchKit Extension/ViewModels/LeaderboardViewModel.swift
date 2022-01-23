import Combine
import Foundation

final class LeaderboardViewModel: NSObject, ObservableObject {
    private var networkService: NetworkService
    
    override init() {
        self.networkService = NetworkService()
    }
    
    func getPublicLeaderboard(page: Int?) {
        Task {
            do {
                let leaderboardData = try await networkService.getPublicLeaderboard(page: page)
                
                DispatchQueue.main.async {
                }
            } catch {
                print("Failed to get leaderboard with error: \(error)")
            }
        }
    }
}
