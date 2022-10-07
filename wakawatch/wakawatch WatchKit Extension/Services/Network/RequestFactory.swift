import Foundation

final class RequestFactory {
    private var accessToken: String?
    private var complicationsFunctionUrl: String?
    private let tokenManager: TokenManager
    private let baseUrl = "https://wakatime.com/api/v1"

    init(tokenManager: TokenManager) {
        self.complicationsFunctionUrl = Bundle.main.infoDictionary?["AZURE_FUNCTION_COMPLICATIONS_URL"] as? String
        self.tokenManager = tokenManager
    }

    func makeSummaryRequest(_ range: SummaryRange = .Today) -> URLRequest {
        var urlComponents = URLComponents(string: "\(baseUrl)/users/current/summaries")!
        urlComponents.queryItems = [
            URLQueryItem(name: "range", value: range.rawValue)
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Bearer \(self.tokenManager.getAccessToken())", forHTTPHeaderField: "Authorization")

        return request
    }

    func makeProfileRequest(_ userId: String?) -> URLRequest {
        var url = "\(baseUrl)/users/current"
        if userId != nil {
            url = "\(baseUrl)/users/\(userId!)"
        }

        let urlComponents = URLComponents(string: url)!

        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Bearer \(self.tokenManager.getAccessToken())", forHTTPHeaderField: "Authorization")

        return request
    }

    func makeGoalsRequest() -> URLRequest {
        let url = "\(baseUrl)/users/current/goals"

        let urlComponents = URLComponents(string: url)!
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Bearer \(self.tokenManager.getAccessToken())", forHTTPHeaderField: "Authorization")

        return request
    }

    func makeLeaderboardRequest(_ boardId: String?, _ page: Int?) -> URLRequest {
        let baseLeaderboardUrl = boardId == nil ? "\(baseUrl)/leaders" : "\(baseUrl)/users/current/leaderboards/\(boardId!)"
        
        var urlComponents = URLComponents(string: baseLeaderboardUrl)!
        var urlQueryItems: [URLQueryItem] = []

        if page != nil {
            urlQueryItems.append(URLQueryItem(name: "page", value: String(page!)))
            urlComponents.queryItems = urlQueryItems
        }

        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Bearer \(self.tokenManager.getAccessToken())", forHTTPHeaderField: "Authorization")

        return request
    }
    
    func makePrivateLeaderboardsRequest() -> URLRequest {
        var urlComponents = URLComponents(string: "\(baseUrl)/users/current/leaderboards")!
        
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Bearer \(self.tokenManager.getAccessToken())", forHTTPHeaderField: "Authorization")

        return request
    }

    func makeExternalDurationsRequest() -> URLRequest {
        var urlComponents = URLComponents(string: "\(baseUrl)/users/current/external_durations")!
        urlComponents.queryItems = [
            URLQueryItem(name: "date", value: DateUtility.getFormattedCurrentDate())
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Bearer \(self.tokenManager.getAccessToken())", forHTTPHeaderField: "Authorization")

        return request
    }

    func makeComplicationsUpdateRequest() -> URLRequest? {
        let accessToken = self.tokenManager.getAccessToken()
        if accessToken.trim().isEmpty { // TODO: Determine why access token is sometimes empty.
            return nil
        }

        let url = "\(self.complicationsFunctionUrl!)&access_token=\(accessToken)"

        let urlComponents = URLComponents(string: url)!
        return URLRequest(url: urlComponents.url!)
    }
}
