import Foundation

struct Objective: Identifiable, Hashable {
    let id: UUID
    var title: String
    var colorHex: String?
    var endDate: Date?
    var keyResults: [KeyResult]
    var completedAt: Date?
    var archivedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        colorHex: String? = nil,
        endDate: Date? = nil,
        keyResults: [KeyResult] = [],
        completedAt: Date? = nil,
        archivedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.endDate = endDate
        self.keyResults = keyResults
        self.completedAt = completedAt
        self.archivedAt = archivedAt
    }

    var progress: Double {
        guard !keyResults.isEmpty else { return 0 }
        let total = keyResults.reduce(0) { $0 + $1.progress }
        return min(max(total / Double(keyResults.count), 0), 1)
    }

    var isArchived: Bool {
        archivedAt != nil
    }
}
