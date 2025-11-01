import Foundation

struct Session: Identifiable, Hashable {
    let id: UUID
    var startedAt: Date
    var duration: TimeInterval

    init(
        id: UUID = UUID(),
        startedAt: Date,
        duration: TimeInterval
    ) {
        self.id = id
        self.startedAt = startedAt
        self.duration = duration
    }
}
