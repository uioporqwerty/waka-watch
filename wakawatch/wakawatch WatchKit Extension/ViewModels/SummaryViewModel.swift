import Combine
import Foundation

final class SummaryViewModel: NSObject, ObservableObject {
    @Published var totalDisplayTime = ""
    @Published var loaded = false
    
    private var networkService: NetworkService
    
    override init() {
        self.networkService = NetworkService()
    }
    
    func getSummary() {
        Task {
            do {
                let summaryData = try await networkService.getSummaryData()
                
                DispatchQueue.main.async {
                    self.totalDisplayTime = summaryData.cummulative_total.text
                    self.loaded = true
                }
            } catch {
                print("Failed to get summary with error: \(error)")
            }
        }
    }
}
