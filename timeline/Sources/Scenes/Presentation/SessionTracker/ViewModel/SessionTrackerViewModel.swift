import Foundation
import Observation

@MainActor
@Observable
final class SessionTrackerViewModel {
    let useCases: SessionTrackerUseCases
    let haptics: HapticBox
    let liveActivityController: any SessionLiveActivityControlling

    var objectives: [Objective]
    var activities: [Activity]
    var activityDraft: ActivityDraft?
    var sessionStartDate: Date?

    init(
        useCases: SessionTrackerUseCases,
        haptics: HapticBox? = nil,
        liveActivityController: (any SessionLiveActivityControlling)? = nil
    ) {
        self.useCases = useCases
        self.haptics = haptics ?? DefaultHapticBox()
        self.liveActivityController = liveActivityController ?? SessionLiveActivityControllerFactory.make()
        self.objectives = []
        self.activities = []

        Task {
            await loadInitialData()
        }
    }

    func updateCompletionStatus(for objective: inout Objective, now: @autoclosure () -> Date = .now) {
        let isComplete = objective.progress >= 1
        if isComplete {
            if objective.completedAt == nil {
                objective.completedAt = now()
            }
        } else {
            objective.completedAt = nil
        }
    }
}
