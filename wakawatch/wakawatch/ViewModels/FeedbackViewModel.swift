import Foundation
import RollbarNotifier

final class FeedbackViewModel: ObservableObject {
    @Published var feedback = ""
    @Published var isSubmissionSuccessful: Bool?
    @Published var isSubmitting = false

    private let networkService: NetworkService
    private let logManager: LogManager
    private let githubAPIService: GithubAPIService

    public let telemetry: TelemetryService

    init(networkService: NetworkService,
         telemetryService: TelemetryService,
         logManager: LogManager,
         githubAPIService: GithubAPIService
        ) {
        self.networkService = networkService
        self.telemetry = telemetryService
        self.logManager = logManager
        self.githubAPIService = githubAPIService
    }

    func submit(completionHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.isSubmitting = true
        }

        self.githubAPIService.createFeature(body: self.feedback.trim(),
                                            completionHandler: {
                                                DispatchQueue.main.async {
                                                    self.isSubmissionSuccessful = true
                                                    self.isSubmitting = false
                                                }
                                                completionHandler?()
                                            },
                                            errorHandler: {
                                                DispatchQueue.main.async {
                                                    self.isSubmissionSuccessful = false
                                                    self.isSubmitting = false
                                                }
                                            })
    }
}
