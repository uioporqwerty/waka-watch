import Foundation

final class LogManager {
    static let shared = LogManager()
    private var loggingService: LoggingService
    
    private init() {
        //TODO: Inject the appropriate service from composition root.
        #if DEBUG
            self.loggingService = ConsoleLoggingService()
        #else
            self.loggingService = RollbarLoggingService()
        #endif
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
    
    func recordNetworkEvent(level: SeverityLevel, method: String?, url: String?, statusCode: String?) {
        self.loggingService.recordNetworkEvent(level: level, method: method, url: url, statusCode: statusCode)
    }
}
