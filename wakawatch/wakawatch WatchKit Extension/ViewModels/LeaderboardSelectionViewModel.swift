import Foundation

final class LeaderboardSelectionViewModel: ObservableObject {
    @Published var privateLeaderboards: [PrivateLeaderboard] = []
    @Published var missingPrivateLeaderboardsScope = false
    
    private let network: NetworkService
    private let authentication: AuthenticationService
    
    public let logManager: LogManager
    public let telemetry: TelemetryService
    public let analytics: AnalyticsService
    
    init(networkService: NetworkService,
         authenticationService: AuthenticationService,
         logManager: LogManager,
         telemetryService: TelemetryService,
         analyticsService: AnalyticsService
        ) {
        self.network = networkService
        self.authentication = authenticationService
        self.logManager = logManager
        self.telemetry = telemetryService
        self.analytics = analyticsService
    }
    
    func loadPrivateLeaderboards() async throws {
        var privateLeaderboardsResponse: PrivateLeaderboardsResponse?
        
        do {
            privateLeaderboardsResponse = try await self.network.getPrivateLeaderboards()
        } catch WakaTimeError.missingScopes {
            DispatchQueue.main.async {
                self.missingPrivateLeaderboardsScope = true
            }
        }
        
        guard let privateLeaderboards = privateLeaderboardsResponse?.data else {
            return
        }
        
        DispatchQueue.main.async {
            var leaderboards: [PrivateLeaderboard] = []
            for leaderboard in privateLeaderboards {
                let viewModel = DependencyInjection
                    .shared
                    .container
                    .resolve(LeaderboardViewModel.self)!
                viewModel.boardId = leaderboard.id
                leaderboards.append(PrivateLeaderboard(id: UUID(uuidString: leaderboard.id)!,
                                                       name: leaderboard.name,
                                                       viewModel: viewModel))
            }
            
            self.privateLeaderboards = leaderboards
        }
    }
    
    func disconnect() async throws {
        self.telemetry.recordViewEvent(elementName: "TAPPED: Disconnect button")
        self.analytics.track(event: "Disconnect from Leaderboard Selection View")
        
        do {
            try await self.authentication.disconnect()

            self.telemetry
                .recordNavigationEvent(from: String(describing: LeaderboardSelectionView.self),
                                       to: String(describing: ConnectView.self))
        } catch {
            self.logManager.reportError(error)
        }
    }
}

struct PrivateLeaderboard: Identifiable {
    let id: UUID
    let name: String
    let viewModel: LeaderboardViewModel
}
