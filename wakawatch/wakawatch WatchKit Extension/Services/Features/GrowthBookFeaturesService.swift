import Foundation
import GrowthBook

class GrowthBookFeaturesService: FeaturesService {
    private var gb: GrowthBookSDK
    
    init(analytics: AnalyticsService) throws {
        let url = Bundle.main.infoDictionary?["GROWTHBOOK_SDK_ENDPOINT"] as? String
        guard let url = url else {
            throw RuntimeError("GROWTHBOOK_SDK_ENDPOINT not found.")
        }
        
        let attributes: [String: Any] = [
            "id": UserDefaults.standard.string(forKey: DefaultsKeys.userId) ?? "",
            "loggedIn": UserDefaults.standard.bool(forKey: DefaultsKeys.authorized)
        ]
        
        self.gb = GrowthBookBuilder(url: url,
                                    attributes: attributes,
                                    trackingCallback: { _, _ in
            
        }).initializer()
    }
    
    func isOn(_ feature: String) -> Bool {
        return self.gb.isOn(feature: feature)
    }
}
