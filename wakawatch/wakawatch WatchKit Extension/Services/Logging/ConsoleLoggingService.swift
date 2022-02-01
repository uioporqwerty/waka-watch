final class ConsoleLoggingService: LoggingService {
    func infoMessage(_ message: String) {
        print("INFO: \(message)")
    }
    
    func errorMessage(_ message: String) {
        print("ERROR: \(message)")
    }
    
    func reportError(_ error: Error) {
        print("ERROR: \(error)")
    }
}
