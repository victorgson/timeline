import Foundation

@MainActor
protocol SessionTrackerRepository {
    func loadObjectives() -> [Objective]
    func loadActivities() -> [Activity]
    func upsertObjective(_ objective: Objective)
    func recordActivity(_ activity: Activity)
    func updateActivity(_ activity: Activity)
    func removeActivity(withID id: UUID)
    @discardableResult
    func createObjective(
        title: String,
        colorHex: String?,
        keyResults: [KeyResult]
    ) -> Objective
}
