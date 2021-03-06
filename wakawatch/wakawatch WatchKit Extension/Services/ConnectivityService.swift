import Foundation
import Combine
import WatchConnectivity

// TODO: Revisit connectivity implementation so it isn't a singleton.
// Already tried registering a singleton instance in Swinject
// but results in connectivity issues since each container will have different instances.
final class ConnectivityService: NSObject {
    static let shared = ConnectivityService()

    private let logManager: LogManager
    private let tokenManager: TokenManager

    private override init() {
        self.logManager = DependencyInjection.shared.container.resolve(LogManager.self)!
        self.tokenManager = DependencyInjection.shared.container.resolve(TokenManager.self)!

        super.init()
        #if !os(watchOS)
            guard WCSession.isSupported() else {
                self.logManager.errorMessage("WCSession is not supported")
                return
            }
        #endif
        WCSession.default.delegate = self
        WCSession.default.activate()
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
            WCSession.default.sendMessage(
              message,
              replyHandler: optionalMainQueueDispatch(handler: replyHandler),
              errorHandler: optionalMainQueueDispatch(handler: errorHandler)
            )
        case .guaranteed:
            WCSession.default.transferUserInfo(message)
        case .highPriority:
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
        setAuthenticationStatus(from: message)
    }

    func session(_ session: WCSession,
                 didReceiveUserInfo userInfo: [String: Any] = [:]) {
        setAuthenticationStatus(from: userInfo)
    }

    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String: Any]) {
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
        self.tokenManager.setAccessToken(accessToken)
        self.tokenManager.setRefreshToken(refreshToken)
        defaults.set(tokenExpiration, forKey: DefaultsKeys.tokenExpiration)
        defaults.set(authorized, forKey: DefaultsKeys.authorized)

        if authorized {
            NotificationCenter.default.post(name: Notification.Name("ScheduleBackgroundTasks"),
                                            object: nil)
        }
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) { }

        func sessionDidDeactivate(_ session: WCSession) {
            WCSession.default.activate()
        }

        func sessionWatchStateDidChange(_ session: WCSession) {
            if WCSession.default.isWatchAppInstalled {
                NotificationCenter.default.post(name: Notification.Name("WatchAppInstallation"),
                                                object: nil)
            }
        }
    #endif

    #if os(watchOS)
        func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
            WCSession.default.activate()
        }
    #endif
}
