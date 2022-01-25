import RollbarNotifier

final class RollbarLoggingService : LoggingService {
    func infoMessage(_ message: String) {
        Rollbar.infoMessage(message)
    }
}
