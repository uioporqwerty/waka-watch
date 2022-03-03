import Foundation

final class ConsoleLoggingService: LoggingService {
    func infoMessage(_ message: String) {
        print("INFO \(Date.now): \(message)")
    }

    func debugMessage(_ message: String) {
        print("DEBUG \(Date.now): \(message)")
    }

    func debugMessage(_ message: String, data: [String: Any]) {
        print("DEBUG \(Date.now): \(message)")
        for (key, value) in data {
            print("\(key): \(value)")
        }
    }

    func errorMessage(_ message: String) {
        print("ERROR \(Date.now): \(message)")
    }

    func reportError(_ error: Error) {
        print("ERROR \(Date.now): \(error)")
    }
}
