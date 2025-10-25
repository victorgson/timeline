import Foundation

struct Objective: Identifiable, Hashable {
    let id: UUID
    var title: String
    var colorHex: String?
    var keyResults: [KeyResult]

    init(
        id: UUID = UUID(),
        title: String,
        colorHex: String? = nil,
        keyResults: [KeyResult] = []
    ) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.keyResults = keyResults
    }

    var progress: Double {
        guard !keyResults.isEmpty else { return 0 }
        let total = keyResults.reduce(0) { $0 + $1.progress }
        return min(max(total / Double(keyResults.count), 0), 1)
    }
}
