import Foundation
import Observation

@Observable
final class ActivityLinkSheetViewModel {
    var selectedObjectiveID: UUID?
    var selectedTimeKeyResultIDs: Set<UUID>
    var quantityValues: [UUID: Double]
    var note: String
    var tagsText: String

    init(draft: SessionTrackerViewModel.ActivityDraft) {
        self.selectedObjectiveID = draft.selectedObjectiveID
        self.selectedTimeKeyResultIDs = Set(draft.selectedTimeAllocations.keys)
        self.quantityValues = draft.quantityValues
        self.note = draft.note
        self.tagsText = draft.tagsText
    }

    func updateQuantityValues(_ values: [UUID: Double]) {
        quantityValues = values
    }

    func setTimeSelection(_ isSelected: Bool, for keyResultID: UUID) {
        if isSelected {
            selectedTimeKeyResultIDs.insert(keyResultID)
        } else {
            selectedTimeKeyResultIDs.remove(keyResultID)
        }
    }

    func setQuantityValue(_ value: Double, for keyResultID: UUID) {
        quantityValues[keyResultID] = value
    }
}
