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
    public let analytics: AnalyticsService
    
    init(networkService: NetworkService,
         telemetryService: TelemetryService,
         analyticsService: AnalyticsService,
         logManager: LogManager
        ) {
        self.networkService = networkService
        self.telemetry = telemetryService
        self.analytics = analyticsService
        self.logManager = logManager
    }

    func getProfile(user: UserData?) async throws {
        if user == nil {
            let userProfileData = try await networkService.getProfileData(userId: nil)
            let leaderboardData = try await networkService.getPublicLeaderboard(page: nil)
            
            guard let profile = userProfileData else {
                return
            }
            
            self.analytics.identifyUser(id: profile.data.id)
            self.analytics.setProfile(properties: [
                "$email": profile.data.email,
                "$avatar": profile.data.photo != nil ? "\(profile.data.photo!)?s=420" : "",
                "$distinct_id": profile.data.id,
                "$name": profile.data.full_name
            ])
            
            DispatchQueue.main.async {
                self.id = UUID(uuidString: profile.data.id)
                self.displayName = profile.data.display_name ?? ""
                self.photoUrl = URL(string: profile.data.photo ?? "")
                self.website = URL(string: profile.data.website ?? "")
                self.createdDate = DateUtility.getDate(date: profile.created_at ?? "")
                self.location = profile.data.city?.title
                self.rank = leaderboardData?.current_user?.rank
                self.bio = profile.data.bio
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
