import RollbarNotifier

final class RollbarTelemetryService: TelemetryService {
    func recordNetworkEvent(level: SeverityLevel, method: String?, url: String?, statusCode: String?) {
        Rollbar.recordNetworkEvent(for: toRollbarLevel(level), method: method, url: url, statusCode: statusCode)
    }
    
    private func toRollbarLevel(_ level: SeverityLevel) -> RollbarLevel {
        if level == .error {
            return .error
        }
        else if level == .critical {
            return .critical
        }
        else if level == .debug {
            return .debug
        }
        else if level == .info {
            return .info
        }
        
        return .warning
    }
}
