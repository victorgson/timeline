import Foundation

public protocol TrackableValue {
    var stringValue: String { get }
}

extension String: TrackableValue {
    public var stringValue: String {
        self
    }
}

extension Int: TrackableValue {
    public var stringValue: String {
        String(self)
    }
}

extension Double: TrackableValue {
    public var stringValue: String {
        String(self)
    }
}

extension Bool: TrackableValue {
    public var stringValue: String {
        self ? "true" : "false"
    }
}
