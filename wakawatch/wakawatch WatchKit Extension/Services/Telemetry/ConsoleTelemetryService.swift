final class ConsoleTelemetryService: TelemetryService {
    func recordNetworkEvent(method: String?, url: String?, statusCode: String?) {
        print("Method: \(method ?? "") URL: \(url ?? "") statusCode: \(statusCode ?? "")")
    }
    
    func recordViewEvent(elementName: String) {
        print("View: \(elementName)")
    }
}
