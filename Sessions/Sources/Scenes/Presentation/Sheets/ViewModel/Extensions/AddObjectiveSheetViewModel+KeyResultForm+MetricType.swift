extension AddObjectiveSheetViewModel.KeyResultForm {
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
}
