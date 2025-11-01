import Foundation

public extension TrackingEvent {
    enum Example {
        public struct Page: TrackablePageEvent, Equatable {
            public init() {}
        }
        
        public struct Action: TrackableActionEvent {
            public enum Value {
                case action
                case actionTwo
            }
            
            public let value: Value
            
            public init(value: Value) {
                self.value = value
            }
        }
    }
}
