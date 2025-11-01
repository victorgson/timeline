import Foundation
import Tracking

public protocol FirebaseTrackablePageEvent {
    var firebasePage: String { get }
    var firebaseAdditionalParameters: [String: TrackableValue] { get }
}
