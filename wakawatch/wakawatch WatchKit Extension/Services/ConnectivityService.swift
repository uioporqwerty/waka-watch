import Foundation
import Combine
import WatchConnectivity

final class ConnectivityService: NSObject, ObservableObject {
    static let shared = ConnectivityService()
    @Published var authorized: Bool = false
      
    override private init() {
        super.init()
        #if !os(watchOS)
            guard WCSession.isSupported() else {
                return
            }
        #endif
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    public func send(authorized: Bool, errorHandler: ((Error) -> Void)? = nil) {
        guard WCSession.default.activationState == .activated else {
            return
        }
        
        #if os(watchOS)
            guard WCSession.default.isCompanionAppInstalled else {
                return
            }
        #else
            guard WCSession.default.isWatchAppInstalled else {
                return
            }
        #endif
        
        let authorizationInfo: [String: Bool] = [
            DefaultsKeys.authorized: authorized
        ]
        
        self.authorized = !self.authorized
        WCSession.default.transferUserInfo(authorizationInfo)
    }
}


extension ConnectivityService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
  
    func session(
      _ session: WCSession,
      didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        let key = DefaultsKeys.authorized
        guard let authorized = userInfo[key] as? Bool else {
            return
        }
        
        print("updating authorized variable")
        self.authorized = authorized
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {
  
        }

        func sessionDidDeactivate(_ session: WCSession) {
            WCSession.default.activate()
        }
    #endif
}
