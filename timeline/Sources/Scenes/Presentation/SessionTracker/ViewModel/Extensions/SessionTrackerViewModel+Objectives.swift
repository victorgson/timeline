import Foundation

@MainActor
extension SessionTrackerViewModel {
    func handleObjectiveSubmission(_ submission: ObjectiveFormSubmission) {
        Task { await handleObjectiveSubmissionAsync(submission) }
    }

    func label(for activity: Activity, calendar: Calendar = .current) -> String {
        guard let objectiveID = activity.linkedObjectiveID,
              let objective = objectives.first(where: { $0.id == objectiveID }) else {
            return "Session"
        }
        return objective.title
    }

    func objective(withID id: UUID) -> Objective? {
        objectives.first(where: { $0.id == id })
    }

    func colorHex(for objectiveID: UUID?) -> String? {
        guard let id = objectiveID, let objective = objective(withID: id) else { return nil }
        return objective.colorHex
    }
}

private extension SessionTrackerViewModel {
    func handleObjectiveSubmissionAsync(_ submission: ObjectiveFormSubmission) async {
        if let id = submission.id, let index = objectives.firstIndex(where: { $0.id == id }) {
            await updateObjective(at: index, with: submission)
        } else {
            await createObjective(from: submission)
        }
    }

    func updateObjective(at index: Int, with submission: ObjectiveFormSubmission) async {
        var updated = objectives[index]
        updated.title = submission.title
        updated.colorHex = submission.colorHex
        updated.endDate = submission.endDate
        updated.keyResults = submission.keyResults
        objectives[index] = updated

        do {
            try await useCases.upsertObjective.execute(updated)
        } catch {
            assertionFailure("Failed to update objective: \(error)")
        }
    }

    func createObjective(from submission: ObjectiveFormSubmission) async {
        do {
            _ = try await useCases.createObjective.execute(
                title: submission.title,
                colorHex: submission.colorHex,
                endDate: submission.endDate,
                keyResults: submission.keyResults
            )
            objectives = try await useCases.loadObjectives.execute()
        } catch {
            assertionFailure("Failed to create objective: \(error)")
        }
    }
}
