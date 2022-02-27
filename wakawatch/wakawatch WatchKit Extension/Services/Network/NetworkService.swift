protocol NetworkService {
    var logManager: LogManager { get }
    var telemetry: TelemetryService { get }
    var authenticationService: AuthenticationService { get }
    var requestFactory: RequestFactory { get }

    func getSummaryData(_ range: SummaryRange) async -> SummaryResponse?
    func getProfileData(userId: String?) async -> ProfileResponse?
    func getGoalsData() async -> GoalsResponse?
    func getPublicLeaderboard(page: Int?) async -> LeaderboardResponse?
    func getAppInformation() async -> AppInformation?
}
