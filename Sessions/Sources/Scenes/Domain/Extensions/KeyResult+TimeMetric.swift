import Foundation

extension KeyResult {
    struct TimeMetric: Hashable {
        var unit: Unit
        var target: Double
        var logged: Double

        init(unit: Unit, target: Double, logged: Double = 0) {
            self.unit = unit
            self.target = target
            self.logged = logged
        }

        var progressFraction: Double {
            guard target > 0 else { return 0 }
            return min(max(logged / target, 0), 1)
        }
    }
}
