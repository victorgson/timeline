import Foundation
import Observation

@Observable
final class ActivityLinkSheetViewModel {
    var selectedObjectiveID: UUID?
    var quantityValues: [UUID: Double]
    var note: String
    var tagsText: String

    init(draft: SessionTrackerViewModel.ActivityDraft) {
        self.selectedObjectiveID = draft.selectedObjectiveID
        self.quantityValues = draft.quantityValues.mapValues { round($0) }
        self.note = draft.note
        self.tagsText = draft.tagsText
    }

    func updateQuantityValues(_ values: [UUID: Double]) {
        quantityValues = values.mapValues { round($0) }
    }

    func setQuantityValue(_ value: Double, for keyResultID: UUID) {
        quantityValues[keyResultID] = round(value)
    }
}
