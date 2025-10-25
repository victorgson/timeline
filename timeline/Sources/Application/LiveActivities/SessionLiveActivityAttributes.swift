#if canImport(ActivityKit)
import ActivityKit
#endif
import Foundation

#if canImport(ActivityKit)
@available(iOS 16.1, *)
struct SessionLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {}

    let id: UUID
    let startDate: Date

    init(id: UUID = UUID(), startDate: Date) {
        self.id = id
        self.startDate = startDate
    }
}
#endif
