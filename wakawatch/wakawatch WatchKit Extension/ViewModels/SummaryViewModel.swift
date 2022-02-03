import Combine
import Foundation

final class SummaryViewModel: ObservableObject {
    @Published var totalDisplayTime = ""
    @Published var loaded = false
    
    private var networkService: NetworkService
    
    public let telemetry: TelemetryService
    
    init(networkService: NetworkService, telemetryService: TelemetryService) {
        self.networkService = networkService
        self.telemetry = telemetryService
    }
    
    func getSummary() {
        Task {
            do {
                let summaryData = try await networkService.getSummaryData()
                
                DispatchQueue.main.async {
                    self.totalDisplayTime = summaryData?.cummulative_total?.text ?? ""
                    self.loaded = true
                }
            } catch {
                print("Failed to get summary with error: \(error)")
            }
        }
    }
}
