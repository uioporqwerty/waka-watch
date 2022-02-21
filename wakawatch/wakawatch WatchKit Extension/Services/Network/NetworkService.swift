import Foundation

final class NetworkService {
    private var logManager: LogManager
    private var telemetry: TelemetryService
    private var authenticationService: AuthenticationService
    private var requestFactory: RequestFactory

    init(logManager: LogManager,
         telemetry: TelemetryService,
         authenticationService: AuthenticationService,
         requestFactory: RequestFactory) {
        self.logManager = logManager
        self.telemetry = telemetry
        self.authenticationService = authenticationService
        self.requestFactory = requestFactory
    }

    func getSummaryData() async -> SummaryResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeSummaryRequest()

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
