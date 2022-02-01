import Foundation

final class LogManager {
    private var loggingService: LoggingService
    
    init(loggingService: LoggingService) {
        self.loggingService = loggingService
    }
    
    func infoMessage(_ message: String) {
        self.loggingService.infoMessage(message)
    }
    
    func errorMessage(_ message: String) {
        self.loggingService.errorMessage(message)
    }
    
    func errorMessage(_ data: Data) {
        self.loggingService.errorMessage(String(data: data, encoding: .utf8)!)
    }
    
    func reportError(_ error: Error) {
        self.loggingService.reportError(error)
    }
}
