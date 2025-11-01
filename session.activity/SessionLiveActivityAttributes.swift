import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct SessionLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var timerRange: ClosedRange<Date>

        init(timerRange: ClosedRange<Date>) {
            self.timerRange = timerRange
        }
    }

    let id: UUID
    let startDate: Date

    init(id: UUID = UUID(), startDate: Date) {
        self.id = id
        self.startDate = startDate
    }
}
