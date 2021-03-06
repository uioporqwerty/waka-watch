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

        let (data, response) = try await URLSession.shared.data(for: request)
        let urlResponse = response as? HTTPURLResponse

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        if !(urlResponse?.statusCode.isSuccessfulHttpResponseCode() ?? false) {
            self.logManager.errorMessage(data)
            return nil
        }

        do {
            return try JSONDecoder().decode(SummaryResponse.self, from: data)
        } catch {
            self.logManager.errorMessage(String(data: data, encoding: .utf8) ??
                                         "Failed to decode summary response and generate raw json response.")
        }

        return nil
    }

    func getProfileData(userId: String?) async throws -> ProfileResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeProfileRequest(userId)

        let (data, response) = try await URLSession.shared.data(for: request)
        let urlResponse = response as? HTTPURLResponse

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        if !(urlResponse?.statusCode.isSuccessfulHttpResponseCode() ?? false) {
            self.logManager.errorMessage(data)
            return nil
        }

        do {
            return try JSONDecoder().decode(ProfileResponse.self, from: data)
        } catch {
            self.logManager.errorMessage(String(data: data, encoding: .utf8) ??
                                         "Failed to decode profile response and generate raw json response.")
        }
        return nil
    }

    func getGoalsData() async throws -> GoalsResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeGoalsRequest()

        let (data, response) = try await URLSession.shared.data(for: request)
        let urlResponse = response as? HTTPURLResponse

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        if !(urlResponse?.statusCode.isSuccessfulHttpResponseCode() ?? false) {
            self.logManager.errorMessage(data)
            return nil
        }

        do {
            return try JSONDecoder().decode(GoalsResponse.self, from: data)
        } catch {
            self.logManager.errorMessage(String(data: data, encoding: .utf8) ??
                                         "Failed to decode goals response and generate raw json response.")
        }

        return nil
    }

    func getPublicLeaderboard(page: Int?) async throws -> LeaderboardResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makePublicLeaderboardRequest(page)

        let (data, response) = try await URLSession.shared.data(for: request)
        let urlResponse = response as? HTTPURLResponse

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        if !(urlResponse?.statusCode.isSuccessfulHttpResponseCode() ?? false) {
            self.logManager.errorMessage(data)
            return nil
        }

        do {
            return try JSONDecoder().decode(LeaderboardResponse.self, from: data)
        } catch {
            self.logManager.errorMessage(String(data: data, encoding: .utf8) ??
                                         "Failed to decode public leaderboard response and generate raw json response.")
        }

        return nil
    }

    func getAppInformation() async throws -> AppInformation? {
        let request = URLRequest(url: URL(string: Bundle
                                              .main
                                              .infoDictionary?["APP_INFORMATION_URL"] as? String ?? "1.0")!)

        let (data, response) = try await URLSession.shared.data(from: request.url!)
        let urlResponse = response as? HTTPURLResponse

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        if !(urlResponse?.statusCode.isSuccessfulHttpResponseCode() ?? false) {
            self.logManager.errorMessage(data)
            return nil
        }

        do {
            return try JSONDecoder().decode(AppInformation.self, from: data)
        } catch {
            self.logManager.errorMessage(String(data: data, encoding: .utf8) ??
                                         "Failed to decode app information response and generate raw json response.")
        }

        return nil
    }
}
