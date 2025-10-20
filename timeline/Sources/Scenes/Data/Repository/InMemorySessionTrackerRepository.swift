import Foundation

@MainActor
final class InMemorySessionTrackerRepository: SessionTrackerRepository {
    private var objectivesStorage: [Objective]
    private var activitiesStorage: [Activity]
    private var targetsStorage: [UUID: Double]

    init(
        objectives: [Objective] = [],
        activities: [Activity] = [],
        objectiveTargets: [UUID: Double] = [:]
    ) {
        self.objectivesStorage = objectives
        self.activitiesStorage = activities.sorted { $0.date > $1.date }
        self.targetsStorage = objectiveTargets
    }

    func loadObjectives() -> [Objective] {
        objectivesStorage
    }

    func loadActivities() -> [Activity] {
        activitiesStorage
    }

    func loadObjectiveTargets() -> [UUID: Double] {
        targetsStorage
    }

    func upsertObjective(_ objective: Objective) {
        if let index = objectivesStorage.firstIndex(where: { $0.id == objective.id }) {
            objectivesStorage[index] = objective
        } else {
            objectivesStorage.append(objective)
        }
    }

    func setObjectiveTarget(_ value: Double, for objectiveID: UUID) {
        targetsStorage[objectiveID] = value
    }

    func recordActivity(_ activity: Activity) {
        activitiesStorage.insert(activity, at: 0)
    }

    func removeActivity(withID id: UUID) {
        activitiesStorage.removeAll { $0.id == id }
    }

    @discardableResult
    func createObjective(title: String, unit: String, target: Double?) -> Objective {
        let objective = Objective(title: title, progress: 0, unit: unit)
        objectivesStorage.append(objective)
        if let target {
            targetsStorage[objective.id] = target
        }
        return objective
    }
}
