final class ConsoleTelemetryService: TelemetryService {
    func recordNetworkEvent(level: SeverityLevel, method: String?, url: String?, statusCode: String?) {
        print("Severity: \(level) Method: \(method ?? "") URL: \(url ?? "") statusCode: \(statusCode ?? "")")
    }
}
