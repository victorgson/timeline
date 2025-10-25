import Foundation

extension KeyResult {
    struct QuantityMetric: Hashable {
        var unit: String
        var target: Double
        var current: Double

        init(unit: String, target: Double, current: Double = 0) {
            self.unit = unit
            self.target = target
            self.current = current
        }

        var progressFraction: Double {
            guard target > 0 else { return 0 }
            return min(max(current / target, 0), 1)
        }
    }
}
