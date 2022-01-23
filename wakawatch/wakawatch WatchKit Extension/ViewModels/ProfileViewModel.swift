import Combine
import Foundation

final class ProfileViewModel: NSObject, ObservableObject {
    @Published var id: UUID?
    @Published var displayName: String?
    @Published var photoUrl: URL?
    @Published var website: URL?
    @Published var createdDate: Date?
    @Published var location: String?
    
    private var networkService: NetworkService
    
    override init() {
        self.networkService = NetworkService()
    }
    
    func getProfile(userId: String?) {
        Task {
            do {
                let userProfileData = try await networkService.getProfileData(userId: userId)
                
                DispatchQueue.main.async {
                    self.id = UUID(uuidString: userProfileData.data.id)
                    self.displayName = userProfileData.data.display_name
                    self.photoUrl = URL(string: userProfileData.data.photo)
                    self.website = URL(string: userProfileData.data.website)
                    self.createdDate = DateUtility.getDate(date: userProfileData.created_at ?? "")
                    self.location = userProfileData.data.city?.title
                }
            } catch {
                print("Failed to get profile with error: \(error)")
            }
        }
    }
}
