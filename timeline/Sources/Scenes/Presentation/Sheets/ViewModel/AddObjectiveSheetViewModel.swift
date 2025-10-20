import Foundation
import Observation
import SwiftUI

@Observable
final class AddObjectiveSheetViewModel {
    struct KeyResultForm: Identifiable, Hashable {
        let id: UUID
        var title: String
        var targetDescription: String
        var currentValue: String

        init(
            id: UUID = UUID(),
            title: String = "",
            targetDescription: String = "",
            currentValue: String = ""
        ) {
            self.id = id
            self.title = title
            self.targetDescription = targetDescription
            self.currentValue = currentValue
        }

        var trimmedTitle: String {
            title.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var trimmedTarget: String? {
            let trimmed = targetDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        var trimmedCurrent: String? {
            let trimmed = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
    }

    enum Mode {
        case create
        case edit(Objective)
    }

    private(set) var mode: Mode

    var title: String
    var unit: String
    var targetText: String
    var color: Color
    var keyResults: [KeyResultForm]

    init(
        mode: Mode = .create,
        initialTarget: Double? = nil,
        defaultColor: Color = .mint
    ) {
        self.mode = mode
        self.targetText = Self.formatTarget(initialTarget)

        switch mode {
        case .create:
            self.title = ""
            self.unit = "hours"
            self.color = defaultColor
            self.keyResults = [KeyResultForm()]
        case .edit(let objective):
            self.title = objective.title
            self.unit = objective.unit
            self.color = Color(hex: objective.colorHex ?? "") ?? defaultColor
            self.keyResults = objective.keyResults.map {
                KeyResultForm(
                    id: $0.id,
                    title: $0.title,
                    targetDescription: $0.targetDescription ?? "",
                    currentValue: $0.currentValue ?? ""
                )
            }
            if keyResults.isEmpty {
                keyResults = [KeyResultForm()]
            }
        }
    }

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var objectiveID: UUID? {
        switch mode {
        case .create:
            return nil
        case .edit(let objective):
            return objective.id
        }
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedUnit: String {
        let trimmed = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "hours" : trimmed
    }

    var isSaveDisabled: Bool {
        trimmedTitle.isEmpty
    }

    var parsedTarget: Double? {
        let trimmed = targetText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }

    var colorHex: String? {
        color.hexString
    }

    var preparedKeyResults: [KeyResult] {
        keyResults
            .map { form in
                KeyResult(
                    id: form.id,
                    title: form.trimmedTitle,
                    targetDescription: form.trimmedTarget,
                    currentValue: form.trimmedCurrent
                )
            }
            .filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    func addKeyResult() {
        keyResults.append(KeyResultForm())
    }

    func removeKeyResult(id: UUID) {
        keyResults.removeAll { $0.id == id }
        if keyResults.isEmpty {
            keyResults.append(KeyResultForm())
        }
    }

    func makeSubmission() -> ObjectiveFormSubmission {
        ObjectiveFormSubmission(
            id: objectiveID,
            title: trimmedTitle,
            unit: normalizedUnit,
            target: parsedTarget,
            colorHex: colorHex,
            keyResults: preparedKeyResults
        )
    }

    private static func formatTarget(_ target: Double?) -> String {
        guard let target else { return "" }
        if target == floor(target) {
            return String(Int(target))
        }
        return String(target)
    }
}

struct ObjectiveFormSubmission {
    let id: UUID?
    let title: String
    let unit: String
    let target: Double?
    let colorHex: String?
    let keyResults: [KeyResult]
}
