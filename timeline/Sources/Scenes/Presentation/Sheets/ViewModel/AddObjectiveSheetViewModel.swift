import Foundation
import Observation
import SwiftUI

@Observable
final class AddObjectiveSheetViewModel {
    let instanceID = UUID()
    private(set) var mode: Mode

    var title: String
    var color: Color
    var isEndDateEnabled: Bool
    var endDate: Date
    var keyResults: [KeyResultForm]
    private(set) var completedAt: Date?
    private(set) var archivedAt: Date?

    init(
        mode: Mode = .create,
        defaultColor: Color = .mint
    ) {
        self.mode = mode

        switch mode {
        case .create:
            self.title = ""
            self.color = defaultColor
            self.isEndDateEnabled = false
            self.endDate = .now
            self.keyResults = [KeyResultForm(metricType: .quantity)]
            self.completedAt = nil
            self.archivedAt = nil
        case .edit(let objective):
            self.title = objective.title
            self.color = Color(hex: objective.colorHex ?? "") ?? defaultColor
            self.isEndDateEnabled = objective.endDate != nil
            self.endDate = objective.endDate ?? .now
            self.completedAt = objective.completedAt
            self.archivedAt = objective.archivedAt
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

    var preparedEndDate: Date? {
        isEndDateEnabled ? endDate : nil
    }

    var isCompleted: Bool {
        completedAt != nil
    }

    var isArchived: Bool {
        archivedAt != nil
    }

    var canArchive: Bool {
        isEditing && isCompleted && !isArchived
    }

    var canRestore: Bool {
        isEditing && isArchived
    }

    var completedDateText: String? {
        guard let completedAt else { return nil }
        return Self.completedDateFormatter.string(from: completedAt)
    }

    var archivedDateText: String? {
        guard let archivedAt else { return nil }
        return Self.completedDateFormatter.string(from: archivedAt)
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
            endDate: preparedEndDate,
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

    private static let completedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension AddObjectiveSheetViewModel: Identifiable {
    var id: UUID { instanceID }
}
