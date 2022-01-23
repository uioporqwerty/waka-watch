import Combine
import Foundation

final class SummaryViewModel: NSObject, ObservableObject {
    @Published var totalDisplayTime: String = ""
    private var networkService = NetworkService()
    
    func getSummary() {
        Task {
            do {
                let summaryData = try await networkService.getSummaryData()
                print(summaryData)
                DispatchQueue.main.async {
                    self.totalDisplayTime = summaryData.cummulative_total.text
                }
            } catch {
                print("Failed to get summary with error: \(error)")
            }
        }
    }
}
