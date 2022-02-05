protocol LoggingService {
    func infoMessage(_ message: String)
    func debugMessage(_ message: String)
    func debugMessage(_ message: String, data: [String: Any])
    func errorMessage(_ message: String)
    func reportError(_ error: Error)
}
