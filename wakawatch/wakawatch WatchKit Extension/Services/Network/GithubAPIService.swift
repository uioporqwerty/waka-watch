import GithubAPI
import Foundation

class GithubAPIService {
    private let logManager: LogManager
    private let issuesApi: IssuesAPI

    private let owner = "uioporqwerty"
    private let repository = "waka-watch"
    private let assignees = ["uioporqwerty"]
    private let userId: String

    init(logManager: LogManager) throws {
        self.logManager = logManager
        guard let githubApiAccessToken = Bundle.main.infoDictionary?["GITHUB_ACCESS_TOKEN"] as? String else {
            self.logManager.errorMessage("Github API Access token is missing")
            throw RuntimeError("Github API Access token is missing")
        }
        self.issuesApi = IssuesAPI(authentication: TokenAuthentication(token: githubApiAccessToken))
        self.userId = UserDefaults.standard.string(forKey: DefaultsKeys.userId)!
    }

    func createFeature(body: String,
                       completionHandler: ((_ url: URL) -> Void)? = nil,
                       errorHandler: (() -> Void)? = nil) {
        var issue = Issue(title: "New Feature Request [\(self.userId)]")
        issue.assignees = self.assignees
        issue.labels = ["user-feature-request"]
        issue.body = body.trim()

        self.issuesApi.createIssue(owner: self.owner,
                                   repository: self.repository,
                                   issue: issue) { response, error in
            if let error = error {
                self.logManager.reportError(error)
                errorHandler?()
                return
            }

            guard let issueUrl = response?.htmlUrl else {
                self.logManager.errorMessage("Issue url was missing.")
                errorHandler?()
                return
            }

            completionHandler?(URL(string: issueUrl)!)
        }
    }

    func createBug(body: String,
                   completionHandler: ((_ url: URL) -> Void)? = nil,
                   errorHandler: (() -> Void)? = nil) {
        var issue = Issue(title: "New Bug [\(self.userId)]")
        issue.assignees = self.assignees
        issue.labels = ["bug"]
        issue.body = body.trim()

        self.issuesApi.createIssue(owner: self.owner,
                                   repository: self.repository,
                                   issue: issue) { response, error in
            if let error = error {
                self.logManager.reportError(error)
                errorHandler?()
                return
            }

            guard let issueUrl = response?.htmlUrl else {
                self.logManager.errorMessage("Issue url was missing.")
                errorHandler?()
                return
            }

            completionHandler?(URL(string: issueUrl)!)
        }
    }
}
