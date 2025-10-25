import Foundation

extension KeyResult.TimeMetric {
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
}
