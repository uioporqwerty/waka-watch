import Combine
import Foundation

final class LeaderboardViewModel: ObservableObject {
    @Published var records: [LeaderboardRecord] = []
    @Published var currentUserRecord: LeaderboardRecord?
    @Published var loaded = false

    private var previousPage: Int?
    private var nextPage: Int?
    private var totalPages: Int = 0

    private var networkService: NetworkService
    public let telemetry: TelemetryService

    init(networkService: NetworkService, telemetryService: TelemetryService) {
        self.networkService = networkService
        self.telemetry = telemetryService
    }

    func isFirstLeaderboardRecord(_ record: LeaderboardRecord) -> Bool {
        if let first = self.records.first {
            return first == record
        }
        return false
    }

    func isLastLeaderboardRecord(_ record: LeaderboardRecord) -> Bool {
        if let last = self.records.last {
            return last == record
        }
        return false
    }

    func loadPreviousPage() {
        if self.previousPage! <= 0 {
            return
        }

        Task {
            do {
                let leaderboardData = try await networkService.getPublicLeaderboard(page: self.previousPage)
                let leaderboardRecords = self.mapLeaderboardDataToRecord(leaderboardData?.data ?? [])

                DispatchQueue.main.async {
                    self.records = leaderboardRecords + self.records
                }

                self.previousPage = self.previousPage! - 1 >= 0 ? self.previousPage! - 1 : 0
            }
        }
    }

    func loadNextPage() {
        if self.nextPage! >= self.totalPages {
            return
        }

        Task {
            do {
                let leaderboardData = try await networkService.getPublicLeaderboard(page: self.nextPage)
                let leaderboardRecords = self.mapLeaderboardDataToRecord(leaderboardData?.data ?? [])

                DispatchQueue.main.async {
                    self.records.append(contentsOf: leaderboardRecords)
                }

                self.nextPage = self.nextPage! + 1 <= self.totalPages ? self.nextPage! + 1 : self.totalPages
            }
        }
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

    func getPublicLeaderboard(page: Int?) {
        Task {
            do {
                let leaderboardData = try await networkService.getPublicLeaderboard(page: page)

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
                }
            } catch {
                print("Failed to get leaderboard with error: \(error)")
            }
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
