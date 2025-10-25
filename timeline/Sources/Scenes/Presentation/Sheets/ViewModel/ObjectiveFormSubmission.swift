import Foundation

struct ObjectiveFormSubmission {
    let id: UUID?
    let title: String
    let colorHex: String?
    let endDate: Date?
    let keyResults: [KeyResult]
}
