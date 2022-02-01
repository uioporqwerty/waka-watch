import Foundation

final class NetworkService {
    private var accessToken: String?
    private let clientId: String?
    private let clientSecret: String?
    private var baseUrl = "https://wakatime.com/api/v1"
    private var logManager: LogManager
    
    init(logManager: LogManager) {
        self.logManager = logManager
        
        let defaults = UserDefaults.standard
        self.accessToken = defaults.string(forKey: DefaultsKeys.accessToken)
        self.clientId = Bundle.main.infoDictionary?["CLIENT_ID"] as? String
        self.clientSecret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String
    }
    
    func getSummaryData() async throws -> SummaryResponse?  {
        var urlComponents = URLComponents(string: "\(baseUrl)/users/current/summaries")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_secret", value: self.clientSecret),
            URLQueryItem(name: "access_token", value: self.accessToken),
            URLQueryItem(name: "range", value: "Today")
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        
        do {
            let (data, response) = try await URLSession.shared.data(from: request.url!)
            let urlResponse = response as! HTTPURLResponse
            
            if urlResponse.statusCode >= 300 {
                self.logManager.errorMessage(data)
            }

            self.logManager.recordNetworkEvent(level: .info, method: request.httpMethod, url: request.url?.absoluteString, statusCode: urlResponse.statusCode.description)
            
            let summaryResponse = try JSONDecoder().decode(SummaryResponse.self, from: data)
            
            return summaryResponse
        } catch {
            self.logManager.reportError(error)
        }
        
        return nil
    }
    
    func getProfileData(userId: String?) async throws -> ProfileResponse? {
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
        do {
            let (data, response) = try await URLSession.shared.data(from: request.url!)
            let urlResponse = response as! HTTPURLResponse
            
            if urlResponse.statusCode >= 300 {
                self.logManager.errorMessage(data)
            }
            
            self.logManager.recordNetworkEvent(level: .info, method: request.httpMethod, url: request.url?.absoluteString, statusCode: urlResponse.statusCode.description)
            
            let profileResponse = try JSONDecoder().decode(ProfileResponse.self, from: data)
            
            return profileResponse
        } catch {
            self.logManager.reportError(error)
        }
        
        return nil
    }
    
    func getPublicLeaderboard(page: Int?) async throws -> LeaderboardResponse? {
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
        
        do {
            let (data, response) = try await URLSession.shared.data(from: request.url!)
            let urlResponse = response as! HTTPURLResponse
            
            if urlResponse.statusCode >= 300 {
                self.logManager.errorMessage(data)
            }

            self.logManager.recordNetworkEvent(level: .info, method: request.httpMethod, url: request.url?.absoluteString, statusCode: urlResponse.statusCode.description)
            
            let leaderboardResponse = try JSONDecoder().decode(LeaderboardResponse.self, from: data)
            
            return leaderboardResponse
        } catch {
            self.logManager.reportError(error)
        }
        
       return nil
    }
    
    func disconnect() async throws {
        let url = "https://wakatime.com/oauth/revoke"
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_secret", value: self.clientSecret),
            URLQueryItem(name: "access_token", value: self.accessToken),
            URLQueryItem(name: "token", value: self.accessToken)
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        let (_, _) = try await URLSession.shared.data(from: request.url!)
    }
}
