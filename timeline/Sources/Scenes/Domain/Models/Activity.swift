import Foundation

struct Activity: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var duration: TimeInterval
    var linkedObjectiveID: UUID?
    var note: String?
    var tags: [String]
    var keyResultAllocations: [KeyResultAllocation]

    init(
        id: UUID = UUID(),
        date: Date,
        duration: TimeInterval,
        linkedObjectiveID: UUID? = nil,
        note: String? = nil,
        tags: [String] = [],
        keyResultAllocations: [KeyResultAllocation] = []
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.linkedObjectiveID = linkedObjectiveID
        self.note = note
        self.tags = tags
        self.keyResultAllocations = keyResultAllocations
    }
}
