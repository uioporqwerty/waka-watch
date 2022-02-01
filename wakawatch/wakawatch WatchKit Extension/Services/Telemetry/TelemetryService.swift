protocol TelemetryService {
    func recordNetworkEvent(method: String?, url: String?, statusCode: String?)
    func recordViewEvent(elementName: String)
    func recordNavigationEvent(from: String, to: String)
}
