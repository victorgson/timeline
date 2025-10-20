import Foundation

struct Objective: Identifiable, Hashable {
    let id: UUID
    var title: String
    var progress: Double
    var unit: String
    var colorHex: String?
    var keyResults: [KeyResult]

    init(
        id: UUID = UUID(),
        title: String,
        progress: Double = 0,
        unit: String,
        colorHex: String? = nil,
        keyResults: [KeyResult] = []
    ) {
        self.id = id
        self.title = title
        self.progress = progress
        self.unit = unit
        self.colorHex = colorHex
        self.keyResults = keyResults
    }
}

struct KeyResult: Identifiable, Hashable {
    let id: UUID
    var title: String
    var targetDescription: String?
    var currentValue: String?

    init(
        id: UUID = UUID(),
        title: String,
        targetDescription: String? = nil,
        currentValue: String? = nil
    ) {
        self.id = id
        self.title = title
        self.targetDescription = targetDescription
        self.currentValue = currentValue
    }
}

struct Activity: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var duration: TimeInterval
    var linkedObjectiveID: UUID?
    var note: String?
    var tags: [String]

    init(
        id: UUID = UUID(),
        date: Date,
        duration: TimeInterval,
        linkedObjectiveID: UUID? = nil,
        note: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.linkedObjectiveID = linkedObjectiveID
        self.note = note
        self.tags = tags
    }
}
