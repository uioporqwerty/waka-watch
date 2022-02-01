protocol TelemetryService {
    func recordNetworkEvent(level: SeverityLevel, method: String?, url: String?, statusCode: String?)
}
