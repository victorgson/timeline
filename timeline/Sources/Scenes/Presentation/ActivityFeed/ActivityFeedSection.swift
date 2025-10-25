import Foundation

struct ActivityFeedSection: Identifiable, Hashable {
    let id: Date
    var title: String
    var activities: [Activity]
}
