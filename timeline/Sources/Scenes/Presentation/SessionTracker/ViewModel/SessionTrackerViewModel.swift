import Foundation
import Observation

@MainActor
@Observable
final class SessionTrackerViewModel {
    struct ActivityDraft {
        var originalActivity: Activity?
        var startedAt: Date
        var duration: TimeInterval
        var selectedObjectiveID: UUID?
        var selectedTimeAllocations: [UUID: TimeInterval]
        var quantityValues: [UUID: Double]
        var note: String
        var tagsText: String

        var isEditing: Bool {
            originalActivity != nil
        }
    }

    private let repository: SessionTrackerRepository
    private let haptics: HapticBox

    var objectives: [Objective]
    var activities: [Activity]
    var activityDraft: ActivityDraft?
    private var sessionStartDate: Date?

    init(repository: SessionTrackerRepository, haptics: HapticBox = DefaultHapticBox()) {
        self.repository = repository
        self.haptics = haptics
        self.objectives = repository.loadObjectives()
        self.activities = repository.loadActivities()
    }

    var isTimerRunning: Bool {
        sessionStartDate != nil
    }

    var activeSessionStartDate: Date? {
        sessionStartDate
    }

    func startSession(now: Date = .now) {
        guard sessionStartDate == nil else { return }
        sessionStartDate = now
        haptics.triggerImpact(style: .medium)
    }

    func stopSession(now: Date = .now) {
        guard let start = sessionStartDate else { return }
        let duration = now.timeIntervalSince(start)
        sessionStartDate = nil

        guard duration > 0 else { return }

        activityDraft = ActivityDraft(
            originalActivity: nil,
            startedAt: start,
            duration: duration,
            selectedObjectiveID: nil,
            selectedTimeAllocations: [:],
            quantityValues: [:],
            note: "",
            tagsText: ""
        )
        haptics.triggerImpact(style: .light)
    }

    func discardDraft() {
        activityDraft = nil
        haptics.triggerNotification(.warning)
    }

    func deleteActivity(_ activity: Activity) {
        repository.removeActivity(withID: activity.id)
        activities = repository.loadActivities()

        if let objectiveID = activity.linkedObjectiveID {
            applyTimeAllocations(activity.keyResultAllocations, to: objectiveID, adding: false)
        }

        haptics.triggerNotification(.warning)
    }

    func handleObjectiveSubmission(_ submission: ObjectiveFormSubmission) {
        if let id = submission.id, let index = objectives.firstIndex(where: { $0.id == id }) {
            var updated = objectives[index]
            updated.title = submission.title
            updated.colorHex = submission.colorHex
            updated.keyResults = submission.keyResults
            objectives[index] = updated
            repository.upsertObjective(updated)
        } else {
            _ = repository.createObjective(
                title: submission.title,
                colorHex: submission.colorHex,
                keyResults: submission.keyResults
            )
            objectives = repository.loadObjectives()
        }
    }

    func saveDraft(now: Date = .now) {
        guard let draft = activityDraft else { return }

        var tags: [String] = []
        if !draft.tagsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tags = draft.tagsText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        let note = draft.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let allocations = draft.selectedTimeAllocations.map { key, seconds in
            KeyResultAllocation(keyResultID: key, seconds: seconds)
        }

        let activity = Activity(
            id: draft.originalActivity?.id ?? UUID(),
            date: draft.startedAt,
            duration: draft.duration,
            linkedObjectiveID: draft.selectedObjectiveID,
            note: note.isEmpty ? nil : note,
            tags: tags,
            keyResultAllocations: allocations
        )

        if let original = draft.originalActivity {
            repository.updateActivity(activity)

            if let originalObjective = original.linkedObjectiveID {
                applyTimeAllocations(original.keyResultAllocations, to: originalObjective, adding: false)
            }

            if let newObjective = activity.linkedObjectiveID {
                applyTimeAllocations(activity.keyResultAllocations, to: newObjective, adding: true)
                applyQuantityOverrides(draft.quantityValues, to: newObjective)
            }
        } else {
            repository.recordActivity(activity)

            if let objectiveID = activity.linkedObjectiveID {
                applyTimeAllocations(activity.keyResultAllocations, to: objectiveID, adding: true)
                applyQuantityOverrides(draft.quantityValues, to: objectiveID)
            }
        }

        activities = repository.loadActivities()

        activityDraft = nil
        haptics.triggerNotification(.success)
    }

    func setDraftObjective(_ objectiveID: UUID?) {
        guard var draft = activityDraft else { return }
        guard draft.selectedObjectiveID != objectiveID else { return }

        draft.selectedObjectiveID = objectiveID
        draft.selectedTimeAllocations = [:]

        if let objectiveID, let objective = objective(withID: objectiveID) {
            draft.quantityValues = defaultQuantityValues(for: objective)
        } else {
            draft.quantityValues = [:]
        }

        activityDraft = draft
    }

    func setDraftNote(_ note: String) {
        guard var draft = activityDraft else { return }
        draft.note = note
        activityDraft = draft
    }

    func setDraftTags(_ tags: String) {
        guard var draft = activityDraft else { return }
        draft.tagsText = tags
        activityDraft = draft
    }

    func toggleDraftTimeKeyResult(_ keyResultID: UUID, isSelected: Bool) {
        guard var draft = activityDraft else { return }
        if isSelected {
            let existing = draft.selectedTimeAllocations[keyResultID]
            draft.selectedTimeAllocations[keyResultID] = existing ?? draft.duration
        } else {
            draft.selectedTimeAllocations.removeValue(forKey: keyResultID)
        }
        activityDraft = draft
        haptics.triggerImpact(style: .light)
    }

    func setDraftQuantityValue(_ value: Double, for keyResultID: UUID) {
        guard var draft = activityDraft else { return }
        let clamped = max(0, value)
        let previous = draft.quantityValues[keyResultID]
        draft.quantityValues[keyResultID] = clamped
        activityDraft = draft

        if previous != clamped {
            haptics.triggerImpact(style: .light)
        }
    }

    func quantityValue(for keyResultID: UUID) -> Double? {
        activityDraft?.quantityValues[keyResultID]
    }

    func isTimeKeyResultSelected(_ keyResultID: UUID) -> Bool {
        activityDraft?.selectedTimeAllocations[keyResultID] != nil
    }

    func editActivity(_ activity: Activity) {
        var allocations: [UUID: TimeInterval] = [:]
        for allocation in activity.keyResultAllocations {
            allocations[allocation.keyResultID] = allocation.seconds
        }

        var quantityValues: [UUID: Double] = [:]
        if let objectiveID = activity.linkedObjectiveID, let objective = objective(withID: objectiveID) {
            quantityValues = defaultQuantityValues(for: objective)
        }

        activityDraft = ActivityDraft(
            originalActivity: activity,
            startedAt: activity.date,
            duration: activity.duration,
            selectedObjectiveID: activity.linkedObjectiveID,
            selectedTimeAllocations: allocations,
            quantityValues: quantityValues,
            note: activity.note ?? "",
            tagsText: activity.tags.joined(separator: ", ")
        )
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

    func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    func elapsedTimeString(now: Date = .now) -> String {
        guard let start = sessionStartDate else { return "00:00:00" }
        let interval = now.timeIntervalSince(start)
        return formattedTimer(interval)
    }

    func formattedTimer(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func progressValue(for objective: Objective) -> Double {
        min(max(objective.progress, 0), 1)
    }

    private func defaultQuantityValues(for objective: Objective) -> [UUID: Double] {
        objective.keyResults.reduce(into: [UUID: Double]()) { partialResult, keyResult in
            if let quantity = keyResult.quantityMetric {
                partialResult[keyResult.id] = quantity.current
            }
        }
    }

    private func applyQuantityOverrides(_ overrides: [UUID: Double], to objectiveID: UUID) {
        mutateObjective(withID: objectiveID) { objective in
            for (keyResultID, value) in overrides {
                guard let index = objective.keyResults.firstIndex(where: { $0.id == keyResultID }),
                      var quantity = objective.keyResults[index].quantityMetric else { continue }
                quantity.current = max(0, value)
                objective.keyResults[index].quantityMetric = quantity
            }
        }
    }

    private func applyTimeAllocations(_ allocations: [KeyResultAllocation], to objectiveID: UUID, adding: Bool) {
        guard !allocations.isEmpty else { return }
        mutateObjective(withID: objectiveID) { objective in
            for allocation in allocations {
                guard let index = objective.keyResults.firstIndex(where: { $0.id == allocation.keyResultID }),
                      var timeMetric = objective.keyResults[index].timeMetric else { continue }

                let delta = timeMetric.unit.value(from: allocation.seconds)
                let adjusted = timeMetric.logged + (adding ? delta : -delta)
                timeMetric.logged = max(0, adjusted)
                objective.keyResults[index].timeMetric = timeMetric
            }
        }
    }

    private func mutateObjective(withID id: UUID, mutation: (inout Objective) -> Void) {
        guard let index = objectives.firstIndex(where: { $0.id == id }) else { return }
        var objective = objectives[index]
        mutation(&objective)
        objectives[index] = objective
        repository.upsertObjective(objective)
    }
}

extension SessionTrackerViewModel {
    static var preview: SessionTrackerViewModel {
        let deepWork = Objective(
            title: "Deep Work",
            colorHex: "#6366F1",
            keyResults: [
                KeyResult(
                    title: "Log 12 hours of focus",
                    timeMetric: .init(unit: .hours, target: 12, logged: 5.5)
                ),
                KeyResult(
                    title: "Ship three features",
                    quantityMetric: .init(unit: "features", target: 3, current: 1)
                )
            ]
        )

        let recovery = Objective(
            title: "Recovery",
            colorHex: "#22C55E",
            keyResults: [
                KeyResult(
                    title: "Sleep 56 hours",
                    timeMetric: .init(unit: .hours, target: 56, logged: 32)
                ),
                KeyResult(
                    title: "Stretch sessions",
                    quantityMetric: .init(unit: "sessions", target: 14, current: 6)
                )
            ]
        )

        let movement = Objective(
            title: "Movement",
            colorHex: "#F59E0B",
            keyResults: [
                KeyResult(
                    title: "Run 20km",
                    quantityMetric: .init(unit: "km", target: 20, current: 8)
                )
            ]
        )

        let activities: [Activity] = [
            Activity(
                date: Date().addingTimeInterval(-1_800),
                duration: 90 * 60,
                linkedObjectiveID: deepWork.id,
                note: "Flowed through the editor build.",
                tags: ["feature", "heads-down"],
                keyResultAllocations: [
                    KeyResultAllocation(keyResultID: deepWork.keyResults[0].id, seconds: 90 * 60)
                ]
            ),
            Activity(
                date: Date().addingTimeInterval(-14_400),
                duration: 45 * 60,
                linkedObjectiveID: recovery.id,
                note: "Mobility + strength block.",
                keyResultAllocations: [
                    KeyResultAllocation(keyResultID: recovery.keyResults[0].id, seconds: 45 * 60)
                ]
            )
        ]

        let repository = InMemorySessionTrackerRepository(
            objectives: [deepWork, recovery, movement],
            activities: activities
        )

        return SessionTrackerViewModel(repository: repository)
    }
}
