import Foundation
import Observation

@MainActor
@Observable
final class SessionTrackerViewModel {
    let useCases: SessionTrackerUseCases
    let haptics: HapticBox

    var objectives: [Objective]
    var activities: [Activity]
    var activityDraft: ActivityDraft?
    var sessionStartDate: Date?

    init(useCases: SessionTrackerUseCases, haptics: HapticBox = DefaultHapticBox()) {
        self.useCases = useCases
        self.haptics = haptics
        self.objectives = []
        self.activities = []

        Task {
            await loadInitialData()
        }
    }
}
