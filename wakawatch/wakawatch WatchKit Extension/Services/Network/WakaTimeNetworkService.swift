import Foundation

final class WakaTimeNetworkService: NetworkService {
    let logManager: LogManager
    let telemetry: TelemetryService
    let authenticationService: AuthenticationService
    let errorService: ErrorService
    var requestFactory: RequestFactory

    init(logManager: LogManager,
         telemetry: TelemetryService,
         authenticationService: AuthenticationService,
         errorService: ErrorService,
         requestFactory: RequestFactory) {
        self.logManager = logManager
        self.telemetry = telemetry
        self.authenticationService = authenticationService
        self.errorService = errorService
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

        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            await self.errorService.handleWakaTimeError(error: errorResponse.error.toWakaTimeError())
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

        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            await self.errorService.handleWakaTimeError(error: errorResponse.error.toWakaTimeError())
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

        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            await self.errorService.handleWakaTimeError(error: errorResponse.error.toWakaTimeError())
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

    func getLeaderboard(boardId: String?, page: Int?) async throws -> LeaderboardResponse? {
        await self.authenticationService.refreshAccessToken()
        
        let request = self.requestFactory.makeLeaderboardRequest(boardId, page)
       
        let (data, response) = try await URLSession.shared.data(for: request)
        let urlResponse = response as? HTTPURLResponse

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        if !(urlResponse?.statusCode.isSuccessfulHttpResponseCode() ?? false) {
            self.logManager.errorMessage(data)
            return nil
        }

        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            await self.errorService.handleWakaTimeError(error: errorResponse.error.toWakaTimeError())
            return nil
        }

        do {
            return try JSONDecoder().decode(LeaderboardResponse.self, from: data)
        } catch {
            self.logManager.errorMessage(String(data: data, encoding: .utf8) ??
                                         "Failed to decode leaderboard response and generate raw json response.")
        }

        return nil
    }
    
    func getExternalDurations() async throws -> ExternalDurationResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makeExternalDurationsRequest()

        let (data, response) = try await URLSession.shared.data(for: request)
        let urlResponse = response as? HTTPURLResponse

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        if !(urlResponse?.statusCode.isSuccessfulHttpResponseCode() ?? false) {
            self.logManager.errorMessage(data)
            return nil
        }

        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            await self.errorService.handleWakaTimeError(error: errorResponse.error.toWakaTimeError())
            return nil
        }

        do {
            return try JSONDecoder().decode(ExternalDurationResponse.self, from: data)
        } catch {
            self.logManager.errorMessage(String(data: data, encoding: .utf8) ??
                                         "Failed to decode external duration response and generate raw json response.")
        }

        return nil
    }
    
    func getPrivateLeaderboards() async throws -> PrivateLeaderboardsResponse? {
        await self.authenticationService.refreshAccessToken()
        let request = self.requestFactory.makePrivateLeaderboardsRequest()

        let (data, response) = try await URLSession.shared.data(for: request)
        let urlResponse = response as? HTTPURLResponse

        self.telemetry.recordNetworkEvent(method: request.httpMethod,
                                          url: request.url?.absoluteString,
                                          statusCode: urlResponse?.statusCode.description)

        if !(urlResponse?.statusCode.isSuccessfulHttpResponseCode() ?? false) {
            self.logManager.errorMessage(data)
            
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                let wakaTimeError = errorResponse.error.toWakaTimeError()
                await self.errorService.handleWakaTimeError(error: wakaTimeError)
                throw wakaTimeError
            }
            
            return nil
        }

        do {
            return try JSONDecoder().decode(PrivateLeaderboardsResponse.self, from: data)
        } catch {
            self.logManager.errorMessage(String(data: data, encoding: .utf8) ??
                                         "Failed to decode private leaderboards response and generate raw json response.")
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
