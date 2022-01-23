import Foundation
import Combine
import WatchConnectivity

final class ConnectivityService: NSObject, ObservableObject {
    static let shared = ConnectivityService()
    @Published var authorized = false
      
    override private init() {
        super.init()
        #if !os(watchOS)
            guard WCSession.isSupported() else {
                print("WCSession is not supported")
                return
            }
        #endif
        WCSession.default.delegate = self
        WCSession.default.activate()
        print("WCSession activated")
    }
    
    public func sendAuthorizationMessage(accessTokenResponse: AccessTokenResponse,
                                         delivery: Delivery,
                                         replyHandler: (([String: Any]) -> Void)? = nil,
                                         errorHandler: ((Error) -> Void)? = nil) {
        guard canSendToPeer() else {
            print("cannot send to peer")
            return
        }
        
        let authorizationInfo: [String: Any] = [
            DefaultsKeys.authorized: true,
            DefaultsKeys.accessToken: accessTokenResponse.access_token
        ]
        
        switch delivery {
            case .failable:
                print("sending as failable")
                WCSession.default.sendMessage(
                  authorizationInfo,
                  replyHandler: optionalMainQueueDispatch(handler: replyHandler),
                  errorHandler: optionalMainQueueDispatch(handler: errorHandler)
                )
            case .guaranteed:
                print("sending as guaranteed")
                WCSession.default.transferUserInfo(authorizationInfo)
            case .highPriority:
                print("sending as high priority")
                do {
                    try WCSession.default.updateApplicationContext(authorizationInfo)
                } catch {
                    errorHandler?(error)
                }
        }
    }
    
    typealias OptionalHandler<T> = ((T) -> Void)?
    
    private func optionalMainQueueDispatch<T>(handler: OptionalHandler<T>) -> OptionalHandler<T> {
      guard let handler = handler else {
        return nil
      }

      return { item in
        DispatchQueue.main.async {
          handler(item)
        }
      }
    }
    
    private func canSendToPeer() -> Bool {
      guard WCSession.default.activationState == .activated else {
          print("session state is not activated. current state is \(WCSession.default.activationState)")
          return false
      }

      #if os(watchOS)
          guard WCSession.default.isCompanionAppInstalled else {
              print("companion app is not installed")
              return false
          }
      #else
          guard WCSession.default.isWatchAppInstalled else {
              print("watch app is not installed")
              return false
          }
      #endif

      return true
    }
}


extension ConnectivityService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("received immediate messager")
        updateAuthorization(from: message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        print("received user info message")
        updateAuthorization(from: userInfo)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("received application context message")
        updateAuthorization(from: applicationContext)
    }
    
    private func updateAuthorization(from dictionary: [String: Any]) {
        guard let authorized = dictionary[DefaultsKeys.authorized] as? Bool else {
            print("authorized key not found")
            return
        }
        
        guard let accessToken = dictionary[DefaultsKeys.accessToken] as? String else {
            print("access token key not found")
            return
        }
        
        self.authorized = authorized
        
        let defaults = UserDefaults.standard
        defaults.set(accessToken, forKey: DefaultsKeys.accessToken)
        defaults.set(true, forKey: DefaultsKeys.authorized)
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {
  
        }

        func sessionDidDeactivate(_ session: WCSession) {
            print("session deactivated")
            WCSession.default.activate()
        }
    #endif
    
    #if os(watchOS)
        func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
            print("install status did change")
            WCSession.default.activate()
        }
    #endif
}