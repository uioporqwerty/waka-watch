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

    func getSummaryData(_ range: SummaryRange = .Today) async -> SummaryResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeSummaryRequest(range)

        do {
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
        } catch {
            self.logManager.reportError(error)
        }

        return nil
    }

    func getProfileData(userId: String?) async -> ProfileResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeProfileRequest(userId)

        do {
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
        } catch {
            self.logManager.reportError(error)
        }

        return nil
    }

    func getGoalsData() async -> GoalsResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeGoalsRequest()

        do {
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
        } catch {
            self.logManager.reportError(error)
        }

        return nil
    }

    func getPublicLeaderboard(page: Int?) async -> LeaderboardResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makePublicLeaderboardRequest(page)

        do {
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
        } catch {
            self.logManager.reportError(error)
        }

       return nil
    }

    func getAppInformation() async -> AppInformation? {
        let request = URLRequest(url: URL(string: Bundle
                                                  .main
                                                  .infoDictionary?["APP_INFORMATION_URL"] as? String ?? "1.0")!)

        do {
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
        } catch {
            self.logManager.reportError(error)
        }

        return nil
    }
}