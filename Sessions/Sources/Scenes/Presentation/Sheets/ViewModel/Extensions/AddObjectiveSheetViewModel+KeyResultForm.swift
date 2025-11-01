import Foundation

extension AddObjectiveSheetViewModel {
    struct KeyResultForm: Identifiable, Hashable {
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
                return parsedTimeTarget != nil
            case .quantity:
                return !trimmedQuantityUnit.isEmpty && parsedQuantityTarget != nil
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
                let quantityMetric = KeyResult.QuantityMetric(
                    unit: trimmedQuantityUnit,
                    target: target,
                    current: current
                )
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

        private func parseDouble(from text: String) -> Double? {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return Double(trimmed.replacingOccurrences(of: ",", with: "."))
        }
    }
}
