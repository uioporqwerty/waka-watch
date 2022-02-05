import RollbarNotifier

final class RollbarLoggingService: LoggingService {
    func infoMessage(_ message: String) {
        Rollbar.infoMessage(message)
    }

    func debugMessage(_ message: String) {
        Rollbar.debugMessage(message)
    }

    func debugMessage(_ message: String, data: [String: Any]) {
        Rollbar.debugMessage(message, data: data)
    }

    func errorMessage(_ message: String) {
        Rollbar.errorMessage(message)
    }

    func reportError(_ error: Error) {
        Rollbar.errorError(error)
    }
}
