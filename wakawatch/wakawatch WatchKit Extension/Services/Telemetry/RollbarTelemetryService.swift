import RollbarNotifier

final class RollbarTelemetryService: TelemetryService {
    func recordNetworkEvent(method: String?, url: String?, statusCode: String?) {
        Rollbar.recordNetworkEvent(for: .debug, method: method, url: url, statusCode: statusCode)
    }
    
    func recordViewEvent(elementName: String) {
        Rollbar.recordViewEvent(for: .info, element: elementName)
    }
    
    func recordNavigationEvent(from: String, to: String) {
        Rollbar.recordNavigationEvent(for: .info, from: from, to: to)
    }
}
