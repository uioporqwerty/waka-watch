import Foundation
import Combine

final class ComplicationSettingsViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    let telementryService: TelemetryService

    private var networkService: NetworkService
    private var logManager: LogManager

    init(networkService: NetworkService,
         telemetryService: TelemetryService,
         logManager: LogManager
    ) {
        self.networkService = networkService
        self.telementryService = telemetryService
        self.logManager = logManager
    }

    func getGoals() async throws {
        let goals = try await self.networkService.getGoalsData()
        let activeGoals = goals?.data.filter { goal in
            return goal.is_enabled && !goal.is_snoozed
        }.sorted(by: {
            // swiftlint:disable line_length
            DateUtility.getDate(date: $0.created_at, includeTime: true)! < DateUtility.getDate(date: $1.created_at, includeTime: true)!
        })

        let defaults = UserDefaults.standard

        // swiftlint:disable line_length
        let complicationGoals: [UUID] = (defaults.array(forKey: DefaultsKeys.complicationGoals) as? [String])?.compactMap { UUID(uuidString: $0)} ?? []

        DispatchQueue.main.async {
            var viewGoals: [Goal] = []
            for goal in activeGoals ?? [] {
                let activeGoalId = UUID(uuidString: goal.id)!

                viewGoals.append(Goal(id: activeGoalId,
                                      title: goal.title,
                                      selected: complicationGoals.contains(where: { id in
                    activeGoalId == id
                })))
            }

            self.goals = viewGoals
        }
    }

    func setGoals(goals: [String]) {
        if goals.count > 3 {
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(goals, forKey: DefaultsKeys.complicationGoals)
    }
}

struct Goal: Identifiable {
    let id: UUID
    let title: String
    let selected: Bool
}
