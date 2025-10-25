import Foundation

@MainActor
extension SessionTrackerViewModel {
    func loadInitialData() async {
        do {
            objectives = try await useCases.loadObjectives.execute()
        } catch {
            assertionFailure("Failed to load objectives: \(error)")
            objectives = []
        }

        do {
            activities = try await useCases.loadActivities.execute()
        } catch {
            assertionFailure("Failed to load activities: \(error)")
            activities = []
        }
    }

    func deleteActivity(_ activity: Activity) {
        Task { await deleteActivityAsync(activity) }
    }

    private func deleteActivityAsync(_ activity: Activity) async {
        do {
            try await useCases.removeActivity.execute(activity.id)
            activities = try await useCases.loadActivities.execute()
        } catch {
            assertionFailure("Failed to delete activity: \(error)")
        }

        if let objectiveID = activity.linkedObjectiveID {
            applyTimeAllocations(activity.keyResultAllocations, to: objectiveID, adding: false)
        }

        haptics.triggerNotification(DefaultHapticBox.Notification.warning)
    }
}
