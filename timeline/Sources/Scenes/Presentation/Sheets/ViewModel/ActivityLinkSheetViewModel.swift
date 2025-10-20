import Foundation
import Observation

@Observable
final class ActivityLinkSheetViewModel {
    var selectedObjectiveID: UUID?
    var note: String
    var tagsText: String

    init(draft: SessionTrackerViewModel.ActivityDraft) {
        self.selectedObjectiveID = draft.selectedObjectiveID
        self.note = draft.note
        self.tagsText = draft.tagsText
    }
}
