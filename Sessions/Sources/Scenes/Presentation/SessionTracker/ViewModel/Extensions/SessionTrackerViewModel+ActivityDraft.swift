import Foundation

extension SessionTrackerViewModel {
    struct ActivityDraft {
        var originalActivity: Activity?
        var startedAt: Date
        var duration: TimeInterval
        var selectedObjectiveID: UUID?
        var selectedTimeAllocations: [UUID: TimeInterval]
        var quantityValues: [UUID: Double]
        var note: String
        var tagsText: String

        var isEditing: Bool {
            originalActivity != nil
        }
    }
}
