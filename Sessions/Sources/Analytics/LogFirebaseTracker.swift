import Foundation
import Tracking
import TrackingFirebase

public final class LogFirebaseTracker: Tracker {
    public func track(event: TrackableEvent) {
        switch event {
            case let actionEvent as FirebaseTrackableActionEvent where !actionEvent.firebaseAdditionalParameters.isEmpty:
                print("FirebaseAnalytics", "Action: \(actionEvent.firebaseAction) with \(actionEvent.firebaseAdditionalParameters)")
            case let actionEvent as FirebaseTrackableActionEvent:
                print("FirebaseAnalytics", "Action: \(actionEvent.firebaseAction)")
            case let pageEvent as FirebaseTrackablePageEvent where !pageEvent.firebaseAdditionalParameters.isEmpty:
                print("FirebaseAnalytics", "PageView: \(pageEvent.firebasePage) with \(pageEvent.firebaseAdditionalParameters)")
            case let pageEvent as FirebaseTrackablePageEvent:
                print("FirebaseAnalytics", "PageView: \(pageEvent.firebasePage)")
            default: ()
        }
    }
}
