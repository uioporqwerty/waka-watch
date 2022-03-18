import Combine
import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var id: UUID?
    @Published var displayName = "Anonymous User"
    @Published var photoUrl: URL?
    @Published var website: URL?
    @Published var createdDate: Date?
    @Published var location: String?
    @Published var rank: Int?
    @Published var bio: String?
    @Published var loaded = false

    private var networkService: NetworkService
    public let telemetry: TelemetryService
    public let logManager: LogManager

    init(networkService: NetworkService,
         telemetryService: TelemetryService,
         logManager: LogManager
        ) {
        self.networkService = networkService
        self.telemetry = telemetryService
        self.logManager = logManager
    }

    func getProfile(user: UserData?) async throws {
        if user == nil {
            let userProfileData = try await networkService.getProfileData(userId: nil)
            let leaderboardData = try await networkService.getPublicLeaderboard(page: nil)

            DispatchQueue.main.async {
                self.id = UUID(uuidString: userProfileData?.data.id ?? "")
                self.displayName = userProfileData?.data.display_name ?? ""
                self.photoUrl = URL(string: userProfileData?.data.photo ?? "")
                self.website = URL(string: userProfileData?.data.website ?? "")
                self.createdDate = DateUtility.getDate(date: userProfileData?.created_at ?? "")
                self.location = userProfileData?.data.city?.title
                self.rank = leaderboardData?.current_user?.rank
                self.bio = userProfileData?.data.bio
                self.loaded = true
            }
        } else {
            DispatchQueue.main.async {
                self.id = UUID(uuidString: user!.id)
                self.displayName = user!.display_name ?? ""
                self.photoUrl = URL(string: user!.photo ?? "")
                self.website = URL(string: user!.website ?? "")
                self.location = user!.city?.title
                self.bio = user?.bio
                self.loaded = true
            }
        }
    }
}
