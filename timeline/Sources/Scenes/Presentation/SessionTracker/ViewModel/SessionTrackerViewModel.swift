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
    private var objectiveTargets: [UUID: Double]

    init(repository: SessionTrackerRepository, haptics: HapticBox = DefaultHapticBox()) {
        self.repository = repository
        self.haptics = haptics
        self.objectives = repository.loadObjectives()
        self.activities = repository.loadActivities()
        self.objectiveTargets = repository.loadObjectiveTargets()
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
            adjustProgress(for: objectiveID, duration: activity.duration, adding: false)
        }

        haptics.triggerNotification(.warning)
    }

    func handleObjectiveSubmission(_ submission: ObjectiveFormSubmission) {
        if let id = submission.id, let index = objectives.firstIndex(where: { $0.id == id }) {
            var updated = objectives[index]
            updated.title = submission.title
            updated.unit = submission.unit
            updated.colorHex = submission.colorHex
            updated.keyResults = submission.keyResults
            objectives[index] = updated
            repository.upsertObjective(updated)
            applyTargetSubmission(submission.target, for: id)
        } else {
            let objective = repository.createObjective(
                title: submission.title,
                unit: submission.unit,
                target: submission.target,
                colorHex: submission.colorHex,
                keyResults: submission.keyResults
            )
            objectives = repository.loadObjectives()
            objectiveTargets = repository.loadObjectiveTargets()
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
        let activity = Activity(
            id: draft.originalActivity?.id ?? UUID(),
            date: draft.startedAt,
            duration: draft.duration,
            linkedObjectiveID: draft.selectedObjectiveID,
            note: note.isEmpty ? nil : note,
            tags: tags
        )

        if let original = draft.originalActivity {
            repository.updateActivity(activity)

            if let originalObjective = original.linkedObjectiveID {
                adjustProgress(for: originalObjective, duration: original.duration, adding: false)
            }

            if let newObjective = activity.linkedObjectiveID {
                adjustProgress(for: newObjective, duration: activity.duration, adding: true)
            }
        } else {
            repository.recordActivity(activity)

            if let objectiveID = draft.selectedObjectiveID {
                adjustProgress(for: objectiveID, duration: draft.duration, adding: true)
            }
        }

        activities = repository.loadActivities()

        activityDraft = nil
        haptics.triggerNotification(.success)
    }

    func setDraftObjective(_ objectiveID: UUID?) {
        guard var draft = activityDraft else { return }
        draft.selectedObjectiveID = objectiveID
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

    func editActivity(_ activity: Activity) {
        activityDraft = ActivityDraft(
            originalActivity: activity,
            startedAt: activity.date,
            duration: activity.duration,
            selectedObjectiveID: activity.linkedObjectiveID,
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

    func targetValue(for objectiveID: UUID) -> Double? {
        objectiveTargets[objectiveID]
    }

    func setObjectiveTarget(_ value: Double, for objectiveID: UUID) {
        objectiveTargets[objectiveID] = value
        repository.setObjectiveTarget(value, for: objectiveID)
    }

    private func applyTargetSubmission(_ value: Double?, for objectiveID: UUID) {
        if let value {
            objectiveTargets[objectiveID] = value
            repository.setObjectiveTarget(value, for: objectiveID)
        } else {
            objectiveTargets.removeValue(forKey: objectiveID)
            repository.clearObjectiveTarget(for: objectiveID)
        }
    }

    private func adjustProgress(for objectiveID: UUID, duration: TimeInterval, adding: Bool) {
        guard let index = objectives.firstIndex(where: { $0.id == objectiveID }) else { return }

        let target = objectiveTargets[objectiveID] ?? defaultTarget(for: objectives[index])
        guard target > 0 else { return }

        let delta = duration / target
        if adding {
            objectives[index].progress = min(1, objectives[index].progress + delta)
        } else {
            objectives[index].progress = max(0, objectives[index].progress - delta)
        }
        repository.upsertObjective(objectives[index])
    }

    private func defaultTarget(for objective: Objective) -> TimeInterval {
        let lowered = objective.unit.lowercased()
        if lowered.contains("hour") {
            return 3_600.0 * 3 // default 3-hour target
        }
        if lowered.contains("session") {
            return 3.0 // count of sessions
        }
        if lowered.contains("minute") {
            return 3_600.0 // degrade to hour target
        }
        return 1.0
    }
}

extension SessionTrackerViewModel {
    static var preview: SessionTrackerViewModel {
        let deepWork = Objective(
            title: "Deep Work",
            progress: 0.45,
            unit: "hours",
            colorHex: "#6366F1",
            keyResults: [
                KeyResult(title: "Ship three features", targetDescription: "3 features", currentValue: "1 shipped")
            ]
        )
        let learning = Objective(
            title: "Learning",
            progress: 0.3,
            unit: "hours",
            colorHex: "#22C55E",
            keyResults: [
                KeyResult(title: "Finish design course", targetDescription: "12 lessons", currentValue: "5 complete")
            ]
        )
        let recovery = Objective(
            title: "Recovery",
            progress: 0.8,
            unit: "sessions",
            colorHex: "#F59E0B",
            keyResults: [
                KeyResult(title: "Sleep 56 hours", targetDescription: "56h per week", currentValue: "44h logged")
            ]
        )
        let movement = Objective(
            title: "Movement",
            progress: 0.6,
            unit: "hours",
            colorHex: "#14B8A6",
            keyResults: [
                KeyResult(title: "Run 20km", targetDescription: "20km", currentValue: "8km")
            ]
        )
        let experimentation = Objective(
            title: "Build",
            progress: 0.15,
            unit: "sessions",
            colorHex: "#EC4899",
            keyResults: [
                KeyResult(title: "Prototype new idea", targetDescription: "1 prototype")
            ]
        )

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        let activities: [Activity] = [
            Activity(date: today.addingTimeInterval(-1_800), duration: 90 * 60, linkedObjectiveID: deepWork.id, note: "Flowed through the editor build.", tags: ["feature", "heads-down"]),
            Activity(date: today.addingTimeInterval(-14_400), duration: 45 * 60, linkedObjectiveID: movement.id, note: "Mobility + strength block."),
            Activity(date: yesterday.addingTimeInterval(-5_400), duration: 60 * 60, linkedObjectiveID: learning.id, note: "Watched design systems talk.", tags: ["learning"])
        ]

        let repository = InMemorySessionTrackerRepository(
            objectives: [deepWork, learning, recovery, movement, experimentation],
            activities: activities,
            objectiveTargets: [
                deepWork.id: 3_600.0 * 4,
                learning.id: 3_600.0 * 2,
                recovery.id: 3.0,
                movement.id: 3_600.0 * 5,
                experimentation.id: 3.0
            ]
        )

        return SessionTrackerViewModel(repository: repository)
    }
}
