import Foundation

@MainActor
final class InMemorySessionTrackerRepository: SessionTrackerRepository {
    private var objectivesStorage: [Objective]
    private var activitiesStorage: [Activity]

    init(
        objectives: [Objective] = [],
        activities: [Activity] = []
    ) {
        self.objectivesStorage = objectives
        self.activitiesStorage = activities.sorted { $0.date > $1.date }
    }

    func loadObjectives() -> [Objective] {
        objectivesStorage
    }

    func loadActivities() -> [Activity] {
        activitiesStorage
    }

    func upsertObjective(_ objective: Objective) {
        if let index = objectivesStorage.firstIndex(where: { $0.id == objective.id }) {
            objectivesStorage[index] = objective
        } else {
            objectivesStorage.append(objective)
        }
    }

    func recordActivity(_ activity: Activity) {
        activitiesStorage.insert(activity, at: 0)
    }

    func updateActivity(_ activity: Activity) {
        if let index = activitiesStorage.firstIndex(where: { $0.id == activity.id }) {
            activitiesStorage[index] = activity
            activitiesStorage.sort { $0.date > $1.date }
        } else {
            recordActivity(activity)
        }
    }

    func removeActivity(withID id: UUID) {
        activitiesStorage.removeAll { $0.id == id }
    }

    @discardableResult
    func createObjective(
        title: String,
        colorHex: String?,
        keyResults: [KeyResult]
    ) -> Objective {
        let objective = Objective(
            title: title,
            colorHex: colorHex,
            keyResults: keyResults
        )
        objectivesStorage.append(objective)
        return objective
    }
}
