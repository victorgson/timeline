import Foundation

@MainActor
protocol FocusTrackerRepository {
    func loadObjectives() -> [Objective]
    func loadActivities() -> [Activity]
    func loadObjectiveTargets() -> [UUID: Double]
    func upsertObjective(_ objective: Objective)
    func setObjectiveTarget(_ value: Double, for objectiveID: UUID)
    func recordActivity(_ activity: Activity)
    func removeActivity(withID id: UUID)
    @discardableResult
    func createObjective(title: String, unit: String, target: Double?) -> Objective
}
