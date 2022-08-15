import Foundation

final class LocalNetworkService: NetworkService {
    var logManager: LogManager
    var telemetry: TelemetryService
    var authenticationService: AuthenticationService
    var requestFactory: RequestFactory

    init(logManager: LogManager,
         telemetry: TelemetryService,
         authenticationService: AuthenticationService,
         requestFactory: RequestFactory) {
        self.logManager = logManager
        self.telemetry = telemetry
        self.authenticationService = authenticationService
        self.requestFactory = requestFactory
    }

    func getSummaryData(_ range: SummaryRange) async -> SummaryResponse? {
        return SummaryResponse(cummulative_total: CummulativeTotal(text: "1 hrs 30 mins", seconds: 5400),
                               data: nil)
    }

    func getProfileData(userId: String?) async -> ProfileResponse? {
        return ProfileResponse(data: self.makeUser(), created_at: Date.now.ISO8601Format())
    }

    func getGoalsData() async -> GoalsResponse? {
        return GoalsResponse(data: [GoalData(id: UUID().uuidString,
                                             chart_data: [GoalChartData(actual_seconds: 500,
                                                                        goal_seconds: 1000,
                                                                        range: GoalChartRange(date: "2022-03-01",
                                                                                              start: "2022-03-01"),
                                                                        range_status: "success")],
                                             is_enabled: true,
                                             is_snoozed: false,
                                             title: "Code for 1 hour per day",
                                             created_at: "2022-02-27"
                                            )])
    }

    func getPublicLeaderboard(page: Int?) async -> LeaderboardResponse? {
        return LeaderboardResponse(current_user: nil,
                                   data: [LeaderboardData(rank: 1,
                                                          user: self.makeUser())],
                                   page: 1,
                                   total_pages: 1)
    }

    func getAppInformation() async -> AppInformation? {
        return AppInformation(minimum_version: "1.3.0")
    }

    func getExternalDurations() async throws -> ExternalDurationResponse? {
        return nil
    }

    private func makeUser() -> UserData {
        return UserData(id: UUID().uuidString,
                        display_name: "Nitish Sachar",
                        photo: nil,
                        website: "https://nybble.app",
                        email: "nitish.sachar@protonmail.com",
                        bio: "Test bio for local network",
                        city: nil)
    }
}
