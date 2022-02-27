import Foundation

final class RequestFactory {
    private let clientId: String?
    private let clientSecret: String?
    private var accessToken: String?
    private let baseUrl = "https://wakatime.com/api/v1"

    init() {
        self.clientId = Bundle.main.infoDictionary?["CLIENT_ID"] as? String
        self.clientSecret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String
    }

    func makeSummaryRequest(_ range: SummaryRange = .Today) -> URLRequest {
        var urlComponents = URLComponents(string: "\(baseUrl)/users/current/summaries")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_secret", value: self.clientSecret),
            URLQueryItem(name: "access_token", value: self.getAccessToken()),
            URLQueryItem(name: "range", value: range.rawValue)
        ]

        return URLRequest(url: urlComponents.url!)
    }

    func makeProfileRequest(_ userId: String?) -> URLRequest {
        var url = "\(baseUrl)/users/current"
        if userId != nil {
            url = "\(baseUrl)/users/\(userId!)"
        }

        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_secret", value: self.clientSecret),
            URLQueryItem(name: "access_token", value: self.getAccessToken())
        ]

        return URLRequest(url: urlComponents.url!)
    }

    func makeGoalsRequest() -> URLRequest {
        let url = "\(baseUrl)/users/current/goals"

        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_secret", value: self.clientSecret),
            URLQueryItem(name: "access_token", value: self.getAccessToken())
        ]

        return URLRequest(url: urlComponents.url!)
    }

    func makePublicLeaderboardRequest(_ page: Int?) -> URLRequest {
        var urlComponents = URLComponents(string: "\(baseUrl)/leaders")!
        var urlQueryItems = [
            URLQueryItem(name: "client_secret", value: self.clientSecret),
            URLQueryItem(name: "access_token", value: self.getAccessToken())
        ]

        if page != nil {
            urlQueryItems.append(URLQueryItem(name: "page", value: String(page!)))
        }

        urlComponents.queryItems = urlQueryItems

        return URLRequest(url: urlComponents.url!)
    }

    private func getAccessToken() -> String? {
        if self.accessToken == nil || self.accessToken == "" {
            let defaults = UserDefaults.standard
            self.accessToken = defaults.string(forKey: DefaultsKeys.accessToken)
        }

        return self.accessToken
    }
}
