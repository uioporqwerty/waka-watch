import Combine
import Foundation

final class LeaderboardViewModel: ObservableObject {
    @Published var records: [LeaderboardRecord] = []
    @Published var currentUserRecord: LeaderboardRecord?
    @Published var loaded = false
    @Published var firstLoad = true

    public var previousPage: Int?
    public var nextPage: Int?
    public var totalPages: Int = 0
    public var boardId: String?
    
    private var networkService: NetworkService
    public let telemetry: TelemetryService
    public let analyticsService: AnalyticsService
    public let logManager: LogManager

    init(networkService: NetworkService,
         telemetryService: TelemetryService,
         analyticsService: AnalyticsService,
         logManager: LogManager
        ) {
        self.networkService = networkService
        self.telemetry = telemetryService
        self.analyticsService = analyticsService
        self.logManager = logManager
    }

    func loadPreviousPage() async throws {
        self.analyticsService.track(event: "Load Previous Leadboard Page")
        if self.previousPage! <= 0 {
            return
        }

        let leaderboardData = try await networkService.getLeaderboard(boardId: self.boardId, page: self.previousPage)
        let leaderboardRecords = self.mapLeaderboardDataToRecord(leaderboardData?.data ?? [])

        DispatchQueue.main.async {
            self.records.insert(contentsOf: leaderboardRecords, at: 0)
        }

        self.previousPage = self.previousPage! - 1 >= 0 ? self.previousPage! - 1 : 0
    }

    func loadNextPage() async throws {
        self.analyticsService.track(event: "Load Next Leaderboard Page")
        if self.nextPage! >= self.totalPages {
            return
        }

        let leaderboardData = try await networkService.getLeaderboard(boardId: self.boardId, page: self.nextPage)
        let leaderboardRecords = self.mapLeaderboardDataToRecord(leaderboardData?.data ?? [])

        DispatchQueue.main.async {
            self.records.append(contentsOf: leaderboardRecords)
        }

        self.nextPage = self.nextPage! + 1 <= self.totalPages ? self.nextPage! + 1 : self.totalPages
    }

    private func mapLeaderboardDataToRecord(_ leaderboardData: [LeaderboardData]) -> [LeaderboardRecord] {
        var leaderboardRecords: [LeaderboardRecord] = []
        leaderboardData.forEach { data in
            guard let user = data.user else {
                return
            }

            leaderboardRecords.append(LeaderboardRecord(id: UUID(uuidString: user.id)!,
                                                        rank: data.rank,
                                                        displayName: user.display_name,
                                                        user: user))
        }
        return leaderboardRecords
    }

    func getLeaderboard(boardId: String?, page: Int?) async throws {
        let leaderboardData = try await networkService.getLeaderboard(boardId: boardId, page: page)

        DispatchQueue.main.async {
            var leaderboardRecords: [LeaderboardRecord] = []
            leaderboardData?.data.forEach { data in
                guard let user = data.user else {
                    return
                }

                leaderboardRecords.append(LeaderboardRecord(id: UUID(uuidString: user.id)!,
                                                            rank: data.rank,
                                                            displayName: user.display_name,
                                                            user: user))
            }
            self.records = leaderboardRecords

            if self.previousPage == nil && self.nextPage == nil {
                let currentPage = leaderboardData?.page ?? 0
                self.previousPage = currentPage - 1 >= 0 ? currentPage - 1 : 0
                self.nextPage = currentPage + 1 <= (leaderboardData?.total_pages ?? 0) ?
                                currentPage + 1 :
                                (leaderboardData?.total_pages ?? 0)
                self.totalPages = leaderboardData?.total_pages ?? 0
            }

            guard let currentUser = leaderboardData?.current_user?.user else {
                return
            }
            self.currentUserRecord = LeaderboardRecord(id: UUID(uuidString: currentUser.id)!,
                                                       rank: leaderboardData?.current_user?.rank,
                                                       displayName: currentUser.display_name,
                                                       user: currentUser)

            self.loaded = true
            self.firstLoad = false
        }
    }
}

struct LeaderboardRecord: Identifiable, Hashable {
    static func == (lhs: LeaderboardRecord, rhs: LeaderboardRecord) -> Bool {
        return lhs.id == rhs.id
    }

    let id: UUID?
    let rank: Int?
    let displayName: String?
    let user: UserData?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
