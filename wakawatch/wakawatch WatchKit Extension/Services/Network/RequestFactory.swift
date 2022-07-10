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

    func makePublicLeaderboardRequest(_ page: Int?) -> URLRequest {
        var urlComponents = URLComponents(string: "\(baseUrl)/leaders")!
        var urlQueryItems: [URLQueryItem] = []

        if page != nil {
            urlQueryItems.append(URLQueryItem(name: "page", value: String(page!)))
        }

        urlComponents.queryItems = urlQueryItems

        var request = URLRequest(url: urlComponents.url!)
        request.addValue("Bearer \(self.tokenManager.getAccessToken())", forHTTPHeaderField: "Authorization")

        return request
    }

    func makeComplicationsUpdateRequest() -> URLRequest {
        let url = "\(self.complicationsFunctionUrl!)&access_token=\(self.tokenManager.getAccessToken())"

        let urlComponents = URLComponents(string: url)!
        return URLRequest(url: urlComponents.url!)
    }
}
