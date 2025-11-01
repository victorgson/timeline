import Foundation
import Tracking

extension TrackingEvent.Example.Page: FirebaseTrackablePageEvent {
    public var firebasePage: String {
        "page"
    }

    public var firebaseAdditionalParameters: [String: TrackableValue] {
        [:]
    }
}

extension TrackingEvent.Example.Action: FirebaseTrackableActionEvent {
    public var firebaseAction: String {
        switch value {
            case .action: "action_1"
            case .actionTwo: "action_2"
        }
    }

    public var firebaseAdditionalParameters: [String: TrackableValue] {
        switch value {
            default:
                [:]
        }
    }
}
