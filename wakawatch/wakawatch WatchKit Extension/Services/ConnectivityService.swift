import Foundation
import Combine
import WatchConnectivity

final class ConnectivityService: NSObject {
    static let shared = ConnectivityService()
    
    private override init() {
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
    
    public func sendMessage(_ message: [String: Any],
                            delivery: Delivery,
                            replyHandler: (([String: Any]) -> Void)? = nil,
                            errorHandler: ((Error) -> Void)? = nil) {
        guard canSendToPeer() else {
            print("cannot send to peer")
            return
        }
        
        switch delivery {
            case .failable:
                print("sending as failable")
                WCSession.default.sendMessage(
                  message,
                  replyHandler: optionalMainQueueDispatch(handler: replyHandler),
                  errorHandler: optionalMainQueueDispatch(handler: errorHandler)
                )
            case .guaranteed:
                print("sending as guaranteed")
                WCSession.default.transferUserInfo(message)
            case .highPriority:
                print("sending as high priority")
                do {
                    try WCSession.default.updateApplicationContext(message)
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
        setAuthenticationStatus(from: message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        print("received user info message")
        setAuthenticationStatus(from: userInfo)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("received application context message")
        setAuthenticationStatus(from: applicationContext)
    }
    
    private func setAuthenticationStatus(from dictionary: [String: Any]) {
        guard let authorized = dictionary[ConnectivityMessageKeys.authorized] as? Bool else {
            print("authorized key not found")
            return
        }
        
        guard let accessToken = dictionary[ConnectivityMessageKeys.accessToken] as? String else {
            print("access token key not found")
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.set(accessToken, forKey: DefaultsKeys.accessToken)
        defaults.set(authorized, forKey: DefaultsKeys.authorized)
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
