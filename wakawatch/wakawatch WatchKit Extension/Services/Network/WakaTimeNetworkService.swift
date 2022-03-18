import Foundation

final class WakaTimeNetworkService: NetworkService {
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

    func getSummaryData(_ range: SummaryRange = .Today) async throws -> SummaryResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeSummaryRequest(range)

        let (data, response) = try await URLSession.shared.data(from: request.url!)
        let urlResponse = response as? HTTPURLResponse

        if urlResponse?.statusCode ?? 0 >= 300 {
            self.logManager.errorMessage(data)
        }

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        let summaryResponse = try JSONDecoder().decode(SummaryResponse.self, from: data)

        return summaryResponse
    }

    func getProfileData(userId: String?) async throws -> ProfileResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeProfileRequest(userId)

        let (data, response) = try await URLSession.shared.data(from: request.url!)
        let urlResponse = response as? HTTPURLResponse

        if urlResponse?.statusCode ?? 0 >= 300 {
            self.logManager.errorMessage(data)
        }

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        let profileResponse = try JSONDecoder().decode(ProfileResponse.self, from: data)

        return profileResponse
    }

    func getGoalsData() async throws -> GoalsResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeGoalsRequest()

        let (data, response) = try await URLSession.shared.data(from: request.url!)
        let urlResponse = response as? HTTPURLResponse

        if urlResponse?.statusCode ?? 0 >= 300 {
            self.logManager.errorMessage(data)
        }

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        let goalsResponse = try JSONDecoder().decode(GoalsResponse.self, from: data)

        return goalsResponse
    }

    func getPublicLeaderboard(page: Int?) async throws -> LeaderboardResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makePublicLeaderboardRequest(page)

        let (data, response) = try await URLSession.shared.data(from: request.url!)
        let urlResponse = response as? HTTPURLResponse

        if urlResponse?.statusCode ?? 0 >= 300 {
            self.logManager.errorMessage(data)
        }

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        let leaderboardResponse = try JSONDecoder().decode(LeaderboardResponse.self, from: data)

        return leaderboardResponse
    }

    func getAppInformation() async throws -> AppInformation? {
        let request = URLRequest(url: URL(string: Bundle
                                              .main
                                              .infoDictionary?["APP_INFORMATION_URL"] as? String ?? "1.0")!)

        let (data, response) = try await URLSession.shared.data(from: request.url!)
        let urlResponse = response as? HTTPURLResponse

        if urlResponse?.statusCode ?? 0 >= 300 {
            self.logManager.errorMessage(data)
        }
        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)
        let appInformation = try JSONDecoder().decode(AppInformation.self, from: data)

        return appInformation
    }
}
