protocol NetworkService {
    var logManager: LogManager { get }
    var telemetry: TelemetryService { get }
    var authenticationService: AuthenticationService { get }
    var requestFactory: RequestFactory { get }

    func getSummaryData(_ range: SummaryRange) async throws -> SummaryResponse?
    func getProfileData(userId: String?) async throws -> ProfileResponse?
    func getGoalsData() async throws -> GoalsResponse?
    func getLeaderboard(boardId: String?, page: Int?) async throws -> LeaderboardResponse?
    func getExternalDurations() async throws -> ExternalDurationResponse?
    func getPrivateLeaderboards() async throws -> PrivateLeaderboardsResponse?
    func getAppInformation() async throws -> AppInformation?
}
