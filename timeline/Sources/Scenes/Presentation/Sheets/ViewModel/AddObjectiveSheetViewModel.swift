import Foundation
import Observation
import SwiftUI

@Observable
final class AddObjectiveSheetViewModel {
    struct KeyResultForm: Identifiable, Hashable {
        let id: UUID
        var title: String

        var includeTime: Bool
        var timeUnit: KeyResult.TimeMetric.Unit
        var timeTargetText: String
        var timeCurrentText: String

        var includeQuantity: Bool
        var quantityUnit: String
        var quantityTargetText: String
        var quantityCurrentText: String

        init(
            id: UUID = UUID(),
            title: String = "",
            includeTime: Bool = false,
            timeUnit: KeyResult.TimeMetric.Unit = .hours,
            timeTargetText: String = "",
            timeCurrentText: String = "",
            includeQuantity: Bool = false,
            quantityUnit: String = "",
            quantityTargetText: String = "",
            quantityCurrentText: String = ""
        ) {
            self.id = id
            self.title = title
            self.includeTime = includeTime
            self.timeUnit = timeUnit
            self.timeTargetText = timeTargetText
            self.timeCurrentText = timeCurrentText
            self.includeQuantity = includeQuantity
            self.quantityUnit = quantityUnit
            self.quantityTargetText = quantityTargetText
            self.quantityCurrentText = quantityCurrentText
        }

        var trimmedTitle: String {
            title.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var trimmedQuantityUnit: String {
            quantityUnit.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        private func parseDouble(from text: String) -> Double? {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return Double(trimmed.replacingOccurrences(of: ",", with: "."))
        }

        var parsedTimeTarget: Double? {
            parseDouble(from: timeTargetText)
        }

        var parsedTimeCurrent: Double {
            parseDouble(from: timeCurrentText) ?? 0
        }

        var parsedQuantityTarget: Double? {
            parseDouble(from: quantityTargetText)
        }

        var parsedQuantityCurrent: Double {
            parseDouble(from: quantityCurrentText) ?? 0
        }

        var isValid: Bool {
            guard !trimmedTitle.isEmpty else { return false }

            var hasMetric = false

            if includeTime {
                guard let _ = parsedTimeTarget else { return false }
                hasMetric = true
            }

            if includeQuantity {
                guard !trimmedQuantityUnit.isEmpty, let _ = parsedQuantityTarget else { return false }
                hasMetric = true
            }

            return hasMetric
        }

        func makeKeyResult() -> KeyResult? {
            guard isValid else { return nil }

            var timeMetric: KeyResult.TimeMetric?
            if includeTime, let target = parsedTimeTarget {
                let current = max(0, parsedTimeCurrent)
                timeMetric = KeyResult.TimeMetric(unit: timeUnit, target: target, logged: current)
            }

            var quantityMetric: KeyResult.QuantityMetric?
            if includeQuantity, let target = parsedQuantityTarget {
                let current = max(0, parsedQuantityCurrent)
                quantityMetric = KeyResult.QuantityMetric(unit: trimmedQuantityUnit, target: target, current: current)
            }

            return KeyResult(
                id: id,
                title: trimmedTitle,
                timeMetric: timeMetric,
                quantityMetric: quantityMetric
            )
        }
    }

    enum Mode {
        case create
        case edit(Objective)
    }

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
            self.keyResults = [KeyResultForm(includeQuantity: true)]
        case .edit(let objective):
            self.title = objective.title
            self.color = Color(hex: objective.colorHex ?? "") ?? defaultColor
            self.keyResults = objective.keyResults.map { keyResult in
                KeyResultForm(
                    id: keyResult.id,
                    title: keyResult.title,
                    includeTime: keyResult.timeMetric != nil,
                    timeUnit: keyResult.timeMetric?.unit ?? .hours,
                    timeTargetText: Self.formatDouble(keyResult.timeMetric?.target),
                    timeCurrentText: Self.formatDouble(keyResult.timeMetric?.logged),
                    includeQuantity: keyResult.quantityMetric != nil,
                    quantityUnit: keyResult.quantityMetric?.unit ?? "",
                    quantityTargetText: Self.formatDouble(keyResult.quantityMetric?.target),
                    quantityCurrentText: Self.formatDouble(keyResult.quantityMetric?.current)
                )
            }
            if keyResults.isEmpty {
                keyResults = [KeyResultForm(includeQuantity: true)]
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
        keyResults.append(KeyResultForm(includeQuantity: true))
    }

    func removeKeyResult(id: UUID) {
        keyResults.removeAll { $0.id == id }
        if keyResults.isEmpty {
            keyResults.append(KeyResultForm(includeQuantity: true))
        }
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

struct ObjectiveFormSubmission {
    let id: UUID?
    let title: String
    let colorHex: String?
    let keyResults: [KeyResult]
}
