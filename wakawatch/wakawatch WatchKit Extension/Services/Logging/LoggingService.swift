protocol LoggingService {
    func infoMessage(_ message: String)
    func errorMessage(_ message: String)
    func reportError(_ error: Error)
    func recordNetworkEvent(level: SeverityLevel, method: String?, url: String?, statusCode: String?)
}
