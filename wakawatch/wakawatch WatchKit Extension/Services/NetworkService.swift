import Foundation

final class NetworkService {
    private var accessToken: String?
    private var baseUrl = "https://wakatime.com/api/v1"
    private let clientId = "59wzFIXtADCSV7Kff7Ck4aha"
    private let clientSecret = "sec_c99U07N5CM91cWjDCu2OQqO8bpqUiwOlGWjnucUVq6oBuc6ED7AipV7uYP8bHuvgBnnVZ8mEhElUByF8" //TODO: Store securely.
    
    init() {
        let defaults = UserDefaults.standard
        self.accessToken = defaults.string(forKey: DefaultsKeys.accessToken)
    }
    
    func getSummaryData() async throws -> SummaryResponse  {
        var urlComponents = URLComponents(string: "\(baseUrl)/users/current/summaries")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_secret", value: self.clientSecret),
            URLQueryItem(name: "access_token", value: self.accessToken),
            URLQueryItem(name: "range", value: "Today")
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        
        let (data, _) = try await URLSession.shared.data(from: request.url!)
        
        let summaryResponse = try JSONDecoder().decode(SummaryResponse.self, from: data)
        return summaryResponse
    }
    
    func getProfileData(userId: String?) async throws -> ProfileResponse {
        var url = "\(baseUrl)/users/current"
        if (userId != nil) {
            url = "\(baseUrl)/users/\(userId!)"
        }
        
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_secret", value: self.clientSecret),
            URLQueryItem(name: "access_token", value: self.accessToken)
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        
        let (data, _) = try await URLSession.shared.data(from: request.url!)
        
        let profileResponse = try JSONDecoder().decode(ProfileResponse.self, from: data)
        return profileResponse
    }
    
    func getPublicLeaderboard(page: Int?) async throws -> LeaderboardResponse {
        var urlComponents = URLComponents(string: "\(baseUrl)/leaders")!
        var urlQueryItems = [
            URLQueryItem(name: "client_secret", value: self.clientSecret),
            URLQueryItem(name: "access_token", value: self.accessToken)
        ]
        
        if (page != nil) {
            urlQueryItems.append(URLQueryItem(name: "page", value: String(page!)))
        }
        
        urlComponents.queryItems = urlQueryItems
        
        let request = URLRequest(url: urlComponents.url!)
        
        let (data, _) = try await URLSession.shared.data(from: request.url!)
        
        let leaderboardResponse = try JSONDecoder().decode(LeaderboardResponse.self, from: data)
        return leaderboardResponse
    }
}
