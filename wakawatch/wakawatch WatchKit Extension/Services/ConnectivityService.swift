import Foundation
import Combine
import WatchConnectivity

// TODO: Revisit connectivity implementation so it isn't a singleton.
// Already tried registering a singleton instance in Swinject
// but results in connectivity issues since each container will have different instances.
final class ConnectivityService: NSObject {
    static let shared = ConnectivityService()

    private let logManager: LogManager

    private override init() {
        self.logManager = DependencyInjection.shared.container.resolve(LogManager.self)!
        super.init()
        #if !os(watchOS)
            guard WCSession.isSupported() else {
                self.logManager.errorMessage("WCSession is not supported")
                return
            }
        #endif
        WCSession.default.delegate = self
        WCSession.default.activate()

        self.logManager.debugMessage("WCSession activated")
    }

    public func sendMessage(_ message: [String: Any],
                            delivery: Delivery,
                            replyHandler: (([String: Any]) -> Void)? = nil,
                            errorHandler: ((Error) -> Void)? = nil) {
        guard canSendToPeer() else {
            self.logManager.errorMessage("Cannot send to peer")
            return
        }

        switch delivery {
        case .failable:
            self.logManager.debugMessage("Sending as failable")
            WCSession.default.sendMessage(
              message,
              replyHandler: optionalMainQueueDispatch(handler: replyHandler),
              errorHandler: optionalMainQueueDispatch(handler: errorHandler)
            )
        case .guaranteed:
            self.logManager.debugMessage("Sending as guaranteed")
            WCSession.default.transferUserInfo(message)
        case .highPriority:
            self.logManager.debugMessage("Sending as high priority")
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
          // swiftlint:disable:next line_length
          self.logManager.errorMessage("Session state is not activated. Current state is \(WCSession.default.activationState)")
          return false
      }

      #if os(watchOS)
          guard WCSession.default.isCompanionAppInstalled else {
              self.logManager.errorMessage("Companion app is not installed.")
              return false
          }
      #else
          guard WCSession.default.isWatchAppInstalled else {
              self.logManager.errorMessage("Watch App is not installed")
              return false
          }
      #endif

      return true
    }
}

extension ConnectivityService: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) { }

    func session(_ session: WCSession,
                 didReceiveMessage message: [String: Any]) {
        self.logManager.debugMessage("Received immediate message.", data: message)
        setAuthenticationStatus(from: message)
    }

    func session(_ session: WCSession,
                 didReceiveUserInfo userInfo: [String: Any] = [:]) {
        self.logManager.debugMessage("Received user info message", data: userInfo)
        setAuthenticationStatus(from: userInfo)
    }

    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String: Any]) {
        self.logManager.debugMessage("Received application context message", data: applicationContext)
        setAuthenticationStatus(from: applicationContext)
    }

    private func setAuthenticationStatus(from dictionary: [String: Any]) {
        guard let authorized = dictionary[ConnectivityMessageKeys.authorized] as? Bool else {
            self.logManager.errorMessage("Authorized key not found")
            return
        }

        guard let accessToken = dictionary[ConnectivityMessageKeys.accessToken] as? String else {
            self.logManager.errorMessage("Access token key not found")
            return
        }

        guard let refreshToken = dictionary[ConnectivityMessageKeys.refreshToken] as? String else {
            self.logManager.errorMessage("Refresh token key not found")
            return
        }

        guard let tokenExpiration = dictionary[ConnectivityMessageKeys.tokenExpiration] as? String else {
            self.logManager.errorMessage("Token expiration key not found")
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(accessToken, forKey: DefaultsKeys.accessToken)
        defaults.set(refreshToken, forKey: DefaultsKeys.refreshToken)
        defaults.set(tokenExpiration, forKey: DefaultsKeys.tokenExpiration)
        defaults.set(authorized, forKey: DefaultsKeys.authorized)

        self.logManager.debugMessage("Set user defaults for accessToken and authorized")
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {
            self.logManager.debugMessage("Connectivity session became inactive")
        }

        func sessionDidDeactivate(_ session: WCSession) {
            self.logManager.debugMessage("Connectivity session deactivated")
            WCSession.default.activate()
        }
    #endif

    #if os(watchOS)
        func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
            self.logManager.debugMessage("Companion app install status changed")
            WCSession.default.activate()
        }
    #endif
}
