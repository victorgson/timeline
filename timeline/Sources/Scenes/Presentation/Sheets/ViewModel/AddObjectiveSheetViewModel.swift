import Foundation
import Observation

@Observable
final class AddObjectiveSheetViewModel {
    var title: String
    var unit: String
    var targetText: String

    init(title: String = "", unit: String = "hours", targetText: String = "") {
        self.title = title
        self.unit = unit
        self.targetText = targetText
    }

    var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var parsedTarget: Double? {
        let trimmed = targetText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }
}
