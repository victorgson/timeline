import Foundation
import Tracking

@MainActor
extension SessionTrackerViewModel {
    var isTimerRunning: Bool {
        sessionStartDate != nil
    }

    var activeSessionStartDate: Date? {
        sessionStartDate
    }

    func startSession(now: Date = .now) {
        guard sessionStartDate == nil else { return }
        sessionStartDate = now
        trackAction(TrackingEvent.SessionTracker.Action(value: .startSession))
        hapticBox.triggerImpact(style: DefaultHapticBox.Impact.medium)
        Task {
            await liveActivityController.startLiveActivity(startDate: now)
        }
    }

    func stopSession(now: Date = .now) {
        guard let start = sessionStartDate else { return }
        trackAction(TrackingEvent.SessionTracker.Action(value: .stopSession))
        let duration = now.timeIntervalSince(start)
        sessionStartDate = nil
        Task {
            await liveActivityController.endLiveActivity()
        }

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
        trackAction(TrackingEvent.SessionTracker.Action(value: .openActivityDraft(.new)))
        hapticBox.triggerImpact(style: DefaultHapticBox.Impact.light)
    }

    func discardDraft() {
        guard let draft = activityDraft else { return }
        activityDraft = nil
        trackAction(TrackingEvent.SessionTracker.Action(value: .discardActivityDraft(isEditing: draft.isEditing)))
        hapticBox.triggerNotification(DefaultHapticBox.Notification.warning)
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
}
