import Mixpanel
import Foundation

class MixpanelService: AnalyticsService {
    init() {
        // swiftlint:disable force_cast
        let mixpanelToken = Bundle.main.infoDictionary?["MIXPANEL_TOKEN"] as! String
        
        #if os(watchOS)
            Mixpanel.initialize(token: mixpanelToken)
        #else
            Mixpanel.initialize(token: mixpanelToken, trackAutomaticEvents: true)
        #endif
    }
    
    func track(event: String?) {
        Mixpanel.mainInstance().track(event: event)
    }
    
    func identifyUser(id: String) {
        Mixpanel.mainInstance().identify(distinctId: id)
    }
    
    func setProfile(properties: [String: Any?]) {
        var mixpanelProperties: [String: MixpanelType] = [:]
        
        for property in properties {
            mixpanelProperties[property.key] = property.value as? any MixpanelType
        }
        
        Mixpanel.mainInstance().people.set(properties: mixpanelProperties)
    }
    
    func hasOptedOut() -> Bool {
        return Mixpanel.mainInstance().hasOptedOutTracking()
    }
    
    func toggleOptInOptOut() {
        if self.hasOptedOut() {
            Mixpanel.mainInstance().optInTracking()
        } else {
            Mixpanel.mainInstance().optOutTracking()
        }
    }
    
}
