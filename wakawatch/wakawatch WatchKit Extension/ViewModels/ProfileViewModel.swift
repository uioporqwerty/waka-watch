import Combine
import Foundation

final class ProfileViewModel: NSObject, ObservableObject {
    @Published var id: UUID?
    @Published var displayName: String?
    @Published var photoUrl: URL?
    @Published var website: URL?
    @Published var createdDate: Date?
    @Published var location: String?
    @Published var rank: Int?
    
    private var networkService: NetworkService
    
    override init() {
        self.networkService = NetworkService()
    }
    
    func getProfile(userId: String?) {
        Task {
            do {
                let userProfileData = try await networkService.getProfileData(userId: userId)
                let leaderboardData = try await networkService.getPublicLeaderboard(page: nil
                )
                DispatchQueue.main.async {
                    self.id = UUID(uuidString: userProfileData.data.id)
                    self.displayName = userProfileData.data.display_name
                    self.photoUrl = URL(string: userProfileData.data.photo)
                    self.website = URL(string: userProfileData.data.website)
                    self.createdDate = DateUtility.getDate(date: userProfileData.created_at ?? "")
                    self.location = userProfileData.data.city?.title
                    self.rank = leaderboardData.current_user.rank
                }
            } catch {
                print("Failed to get profile with error: \(error)")
            }
        }
    }
}
