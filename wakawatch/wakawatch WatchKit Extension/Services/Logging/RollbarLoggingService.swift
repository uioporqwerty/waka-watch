import RollbarNotifier

final class RollbarLoggingService : LoggingService {
    func infoMessage(_ message: String) {
        Rollbar.infoMessage(message)
    }
    
    func errorMessage(_ message: String) {
        Rollbar.errorMessage(message)
    }
    
    func reportError(_ error: Error) {
        Rollbar.errorError(error)
        
    }
}
