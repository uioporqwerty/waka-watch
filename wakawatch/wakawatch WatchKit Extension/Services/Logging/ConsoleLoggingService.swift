final class ConsoleLoggingService: LoggingService {
    func infoMessage(_ message: String) {
        print("INFO: \(message)")
    }

    func debugMessage(_ message: String) {
        print("DEBUG: \(message)")
    }

    func debugMessage(_ message: String, data: [String: Any]) {
        print("DEBUG: \(message)")
        for (key, value) in data {
            print("\(key): \(value)")
        }
    }

    func errorMessage(_ message: String) {
        print("ERROR: \(message)")
    }

    func reportError(_ error: Error) {
        print("ERROR: \(error)")
    }
}
