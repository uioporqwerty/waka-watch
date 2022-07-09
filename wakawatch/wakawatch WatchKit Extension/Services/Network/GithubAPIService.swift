import GithubAPI
import Foundation

class GithubAPIService {
    private var logManager: LogManager
    private var issuesApi: IssuesAPI

    private let owner = "uioporqwerty"
    private let repository = "waka-watch"

    init(logManager: LogManager) throws {
        self.logManager = logManager
        guard let githubApiAccessToken = Bundle.main.infoDictionary?["GITHUB_ACCESS_TOKEN"] as? String else {
            self.logManager.errorMessage("Github API Access token is missing")
            throw RuntimeError("Github API Access token is missing")
        }
        self.issuesApi = IssuesAPI(authentication: TokenAuthentication(token: githubApiAccessToken))
    }

    func createFeature(body: String,
                       completionHandler: (() -> Void)? = nil,
                       errorHandler: (() -> Void)? = nil) {
        var issue = Issue(title: "New user feature request")
        issue.assignees = ["uioporqwerty"]
        issue.labels = ["user-feature-request"]
        issue.body = body.trim()

        self.issuesApi.createIssue(owner: self.owner,
                                   repository: self.repository,
                                   issue: issue) { _, error in
            if let error = error {
                self.logManager.reportError(error)
                errorHandler?()
                return
            }

            completionHandler?()
        }
    }
}
