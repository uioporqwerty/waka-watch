import Foundation

final class LogManager {
    private var services: [LoggingService]

    init(loggingServices: [LoggingService]) {
        self.services = loggingServices
    }

    func infoMessage(_ message: String) {
        for service in self.services {
            service.infoMessage(message)
        }
    }

    func debugMessage(_ message: String) {
        for service in self.services {
            service.debugMessage(message)
        }
    }

    func debugMessage(_ message: String, data: [String: Any]) {
        for service in self.services {
            service.debugMessage(message, data: data)
        }
    }

    func errorMessage(_ message: String) {
        for service in self.services {
            service.errorMessage(message)
        }
    }

    func errorMessage(_ data: Data) {
        for service in self.services {
            service.errorMessage(String(data: data, encoding: .utf8)!)
        }
    }

    func reportError(_ error: Error) {
        for service in self.services {
            service.reportError(error)
        }
    }
}
