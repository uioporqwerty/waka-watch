protocol AnalyticsService {
    func track(event: String?)
    
    func identifyUser(id: String)
    func setProfile(properties: [String: Any?])
    func hasOptedOut() -> Bool
    func toggleOptInOptOut()
}
