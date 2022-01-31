import Combine
import Foundation

final class ProfileViewModel: NSObject, ObservableObject {
    @Published var id: UUID?
    @Published var displayName = "Anonymous User"
    @Published var photoUrl: URL?
    @Published var website: URL?
    @Published var createdDate: Date?
    @Published var location: String?
    @Published var rank: Int?
    @Published var loaded = false
    
    private var networkService: NetworkService
    
    override init() {
        self.networkService = NetworkService()
    }
    
    func getProfile(user: UserData?) {
        if (user == nil) {
            Task {
                do {
                    let userProfileData = try await networkService.getProfileData(userId: nil)
                    let leaderboardData = try await networkService.getPublicLeaderboard(page: nil)
                    
                    DispatchQueue.main.async {
                        self.id = UUID(uuidString: userProfileData?.data.id ?? "")
                        self.displayName = userProfileData?.data.display_name ?? ""
                        self.photoUrl = URL(string: userProfileData?.data.photo ?? "")
                        self.website = URL(string: userProfileData?.data.website ?? "")
                        self.createdDate = DateUtility.getDate(date: userProfileData?.created_at ?? "")
                        self.location = userProfileData?.data.city?.title
                        self.rank = leaderboardData?.current_user.rank
                        self.loaded = true
                    }
                } catch {
                    print("Failed to get profile with error: \(error)")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.id = UUID(uuidString: user!.id)
                self.displayName = user!.display_name
                self.photoUrl = URL(string: user!.photo)
                self.website = URL(string: user!.website)
                self.location = user!.city?.title
            }
        }
    }
}
