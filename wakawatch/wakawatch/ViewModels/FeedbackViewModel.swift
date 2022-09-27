import Foundation
import RollbarNotifier

final class FeedbackViewModel: ObservableObject {
    @Published var feedback = ""
    @Published var isSubmissionSuccessful: Bool?
    @Published var isSubmitting = false
    @Published var selectedCategory = 0
    @Published var issueUrl: URL?

    private let networkService: NetworkService
    private let logManager: LogManager
    private let githubAPIService: GithubAPIService

    public let telemetry: TelemetryService
    public let analytics: AnalyticsService
    public let categories = ["None", "Feature", "Bug"]

    init(networkService: NetworkService,
         telemetryService: TelemetryService,
         analyticsService: AnalyticsService,
         logManager: LogManager,
         githubAPIService: GithubAPIService
        ) {
        self.networkService = networkService
        self.telemetry = telemetryService
        self.analytics = analyticsService
        self.logManager = logManager
        self.githubAPIService = githubAPIService
    }

    func submit(completionHandler: (() -> Void)? = nil) {
        self.analytics.track(event: "Feedback Submission")
        DispatchQueue.main.async {
            self.isSubmitting = true
        }

        let submissionHandler = { (url: URL) in
            DispatchQueue.main.async {
                self.isSubmissionSuccessful = true
                self.isSubmitting = false
                self.issueUrl = url
            }
            completionHandler?()
        }

        let submissionErrorHandler = { () -> Void in
            DispatchQueue.main.async {
                self.isSubmissionSuccessful = false
                self.isSubmitting = false
            }
        }

        if self.selectedCategory == 1 {
            self.githubAPIService.createFeature(body: self.feedback.trim(),
                                                completionHandler: submissionHandler,
                                                errorHandler: submissionErrorHandler)
        } else {
            self.githubAPIService.createBug(body: self.feedback.trim(),
                                            completionHandler: submissionHandler,
                                            errorHandler: submissionErrorHandler)
        }
    }
}
