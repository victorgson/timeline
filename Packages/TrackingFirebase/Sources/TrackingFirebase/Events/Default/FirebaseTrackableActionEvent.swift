import Foundation
import Tracking

public protocol FirebaseTrackableActionEvent {
    var firebaseAction: String { get }
    var firebaseAdditionalParameters: [String: TrackableValue] { get }
}
