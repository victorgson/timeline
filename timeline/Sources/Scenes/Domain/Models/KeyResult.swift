import Foundation

struct KeyResult: Identifiable, Hashable {
    let id: UUID
    var title: String
    var timeMetric: TimeMetric?
    var quantityMetric: QuantityMetric?

    init(
        id: UUID = UUID(),
        title: String,
        timeMetric: TimeMetric? = nil,
        quantityMetric: QuantityMetric? = nil
    ) {
        self.id = id
        self.title = title
        self.timeMetric = timeMetric
        self.quantityMetric = quantityMetric
    }

    var progress: Double {
        let fractions = [timeMetric?.progressFraction, quantityMetric?.progressFraction]
            .compactMap { $0 }
        guard !fractions.isEmpty else { return 0 }
        let total = fractions.reduce(0, +)
        return min(max(total / Double(fractions.count), 0), 1)
    }
}
