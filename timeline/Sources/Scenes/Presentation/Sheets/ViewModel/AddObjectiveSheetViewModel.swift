import Foundation
import Observation
import SwiftUI

@Observable
final class AddObjectiveSheetViewModel {
    struct KeyResultForm: Identifiable, Hashable {
        enum MetricType: String, CaseIterable, Identifiable {
            case time
            case quantity
            case none

            var id: String { rawValue }

            var displayName: String {
                switch self {
                case .time:
                    return "Time"
                case .quantity:
                    return "Quantity"
                case .none:
                    return "None"
                }
            }
        }

        let id: UUID
        var title: String
        var metricType: MetricType

        var timeUnit: KeyResult.TimeMetric.Unit
        var timeTargetText: String
        var timeCurrentText: String

        var quantityUnit: String
        var quantityTargetText: String
        var quantityCurrentText: String

        init(
            id: UUID = UUID(),
            title: String = "",
            metricType: MetricType = .quantity,
            timeUnit: KeyResult.TimeMetric.Unit = .hours,
            timeTargetText: String = "",
            timeCurrentText: String = "",
            quantityUnit: String = "",
            quantityTargetText: String = "",
            quantityCurrentText: String = ""
        ) {
            self.id = id
            self.title = title
            self.metricType = metricType
            self.timeUnit = timeUnit
            self.timeTargetText = timeTargetText
            self.timeCurrentText = timeCurrentText
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

            switch metricType {
            case .time:
                guard let _ = parsedTimeTarget else { return false }
                return true
            case .quantity:
                guard !trimmedQuantityUnit.isEmpty, let _ = parsedQuantityTarget else { return false }
                return true
            case .none:
                return true
            }
        }

        func makeKeyResult() -> KeyResult? {
            guard isValid else { return nil }

            switch metricType {
            case .time:
                guard let target = parsedTimeTarget else { return nil }
                let current = max(0, parsedTimeCurrent)
                let timeMetric = KeyResult.TimeMetric(unit: timeUnit, target: target, logged: current)
                return KeyResult(
                    id: id,
                    title: trimmedTitle,
                    timeMetric: timeMetric,
                    quantityMetric: nil
                )
            case .quantity:
                guard let target = parsedQuantityTarget else { return nil }
                let current = max(0, parsedQuantityCurrent)
                let quantityMetric = KeyResult.QuantityMetric(unit: trimmedQuantityUnit, target: target, current: current)
                return KeyResult(
                    id: id,
                    title: trimmedTitle,
                    timeMetric: nil,
                    quantityMetric: quantityMetric
                )
            case .none:
                return KeyResult(
                    id: id,
                    title: trimmedTitle,
                    timeMetric: nil,
                    quantityMetric: nil
                )
            }
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

struct ObjectiveFormSubmission {
    let id: UUID?
    let title: String
    let colorHex: String?
    let keyResults: [KeyResult]
}
