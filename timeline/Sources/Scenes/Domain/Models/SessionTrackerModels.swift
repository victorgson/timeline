import Foundation

struct Objective: Identifiable, Hashable {
    let id: UUID
    var title: String
    var colorHex: String?
    var keyResults: [KeyResult]

    init(
        id: UUID = UUID(),
        title: String,
        colorHex: String? = nil,
        keyResults: [KeyResult] = []
    ) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.keyResults = keyResults
    }

    var progress: Double {
        guard !keyResults.isEmpty else { return 0 }
        let total = keyResults.reduce(0) { $0 + $1.progress }
        return min(max(total / Double(keyResults.count), 0), 1)
    }
}

struct KeyResult: Identifiable, Hashable {
    struct TimeMetric: Hashable {
        enum Unit: String, CaseIterable, Hashable {
            case minutes
            case hours

            var displayName: String {
                rawValue.capitalized
            }

            var secondsPerUnit: TimeInterval {
                switch self {
                case .minutes:
                    return 60
                case .hours:
                    return 3_600
                }
            }

            func value(from seconds: TimeInterval) -> Double {
                seconds / secondsPerUnit
            }

            func seconds(from value: Double) -> TimeInterval {
                value * secondsPerUnit
            }
        }

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

struct Activity: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var duration: TimeInterval
    var linkedObjectiveID: UUID?
    var note: String?
    var tags: [String]
    var keyResultAllocations: [KeyResultAllocation]

    init(
        id: UUID = UUID(),
        date: Date,
        duration: TimeInterval,
        linkedObjectiveID: UUID? = nil,
        note: String? = nil,
        tags: [String] = [],
        keyResultAllocations: [KeyResultAllocation] = []
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.linkedObjectiveID = linkedObjectiveID
        self.note = note
        self.tags = tags
        self.keyResultAllocations = keyResultAllocations
    }
}

struct KeyResultAllocation: Hashable {
    let keyResultID: UUID
    var seconds: TimeInterval

    init(keyResultID: UUID, seconds: TimeInterval) {
        self.keyResultID = keyResultID
        self.seconds = seconds
    }
}
