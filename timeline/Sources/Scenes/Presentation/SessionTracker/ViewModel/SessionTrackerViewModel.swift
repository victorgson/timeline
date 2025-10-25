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
        haptics: HapticBox = DefaultHapticBox(),
        liveActivityController: (any SessionLiveActivityControlling)? = nil
    ) {
        self.useCases = useCases
        self.haptics = haptics
        self.liveActivityController = liveActivityController ?? SessionLiveActivityControllerFactory.make()
        self.objectives = []
        self.activities = []

        Task {
            await loadInitialData()
        }
    }
}
