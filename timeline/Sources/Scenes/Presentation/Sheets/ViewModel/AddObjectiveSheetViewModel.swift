import Foundation
import Observation
import SwiftUI

@Observable
final class AddObjectiveSheetViewModel {
    private(set) var mode: Mode

    var title: String
    var color: Color
    var keyResults: [KeyResultForm]

    init(
        mode: Mode = .create,
        defaultColor: Color = .mint
    ) {
        self.mode = mode

        switch mode {
        case .create:
            self.title = ""
            self.color = defaultColor
            self.keyResults = [KeyResultForm(metricType: .quantity)]
        case .edit(let objective):
            self.title = objective.title
            self.color = Color(hex: objective.colorHex ?? "") ?? defaultColor
            self.keyResults = objective.keyResults.map { keyResult in
                let metricType: KeyResultForm.MetricType
                if keyResult.timeMetric != nil, keyResult.quantityMetric == nil {
                    metricType = .time
                } else if keyResult.quantityMetric != nil, keyResult.timeMetric == nil {
                    metricType = .quantity
                } else if keyResult.timeMetric != nil {
                    metricType = .time
                } else if keyResult.quantityMetric != nil {
                    metricType = .quantity
                } else {
                    metricType = .none
                }

                return KeyResultForm(
                    id: keyResult.id,
                    title: keyResult.title,
                    metricType: metricType,
                    timeUnit: keyResult.timeMetric?.unit ?? .hours,
                    timeTargetText: Self.formatDouble(keyResult.timeMetric?.target),
                    timeCurrentText: Self.formatDouble(keyResult.timeMetric?.logged),
                    quantityUnit: keyResult.quantityMetric?.unit ?? "",
                    quantityTargetText: Self.formatDouble(keyResult.quantityMetric?.target),
                    quantityCurrentText: Self.formatDouble(keyResult.quantityMetric?.current)
                )
            }
            if keyResults.isEmpty {
                keyResults = [KeyResultForm(metricType: .quantity)]
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

    var isSaveDisabled: Bool {
        trimmedTitle.isEmpty || preparedKeyResults.isEmpty || keyResults.contains { !$0.isValid }
    }

    var colorHex: String? {
        color.hexString
    }

    var preparedKeyResults: [KeyResult] {
        keyResults.compactMap { $0.makeKeyResult() }
    }

    func addKeyResult() {
        keyResults.append(KeyResultForm(metricType: .quantity))
    }

    func removeKeyResult(id: UUID) {
        keyResults.removeAll { $0.id == id }
        if keyResults.isEmpty {
            keyResults.append(KeyResultForm(metricType: .quantity))
        }
    }

    func updateKeyResult(_ keyResult: KeyResultForm) {
        guard let index = keyResults.firstIndex(where: { $0.id == keyResult.id }) else { return }
        keyResults[index] = keyResult
    }

    func sectionTitle(forKeyResult id: UUID) -> String {
        guard let index = keyResults.firstIndex(where: { $0.id == id }) else {
            return "Key Result"
        }

        let baseTitle = "Key Result \(index + 1)"
        let customTitle = keyResults[index].trimmedTitle

        guard !customTitle.isEmpty else { return baseTitle }
        return "\(baseTitle): \(customTitle)"
    }

    func makeSubmission() -> ObjectiveFormSubmission {
        ObjectiveFormSubmission(
            id: objectiveID,
            title: trimmedTitle,
            colorHex: colorHex,
            keyResults: preparedKeyResults
        )
    }

    private static func formatDouble(_ value: Double?) -> String {
        guard let value else { return "" }
        if value == floor(value) {
            return String(Int(value))
        }
        return String(value)
    }
}
