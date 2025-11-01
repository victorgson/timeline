import FirebaseAnalytics
import Foundation
import Tracking

enum FirebaseTrackerConstants {
    static let userAnswer = "user_answer"
    static let status = "status"
    static let source = "source"
    static let market = "market"

    static let osVersion = "os_with_version"
}

public final class FirebaseTracker: Tracker {
    public init() {
        Analytics.setUserProperty("iOS \(UIDevice.current.systemVersion)", forName: FirebaseTrackerConstants.osVersion)
        Analytics.setAnalyticsCollectionEnabled(true)
    }

    public func track(event: TrackableEvent) {
        switch event {
            case let actionEvent as FirebaseTrackableActionEvent:
                track(actionEvent)
            case let pageEvent as FirebaseTrackablePageEvent:
                track(pageEvent)
            default: ()
        }
    }
}

private extension FirebaseTracker {
    func track(_ event: FirebaseTrackableActionEvent) {
        FirebaseAnalytics.Analytics.logEvent(event.firebaseAction, parameters: event.firebaseAdditionalParameters)
    }

    func track(_ event: FirebaseTrackablePageEvent) {
        var parameters = event.firebaseAdditionalParameters.mapValues { $0.stringValue }
        parameters[AnalyticsParameterScreenName] = event.firebasePage
        FirebaseAnalytics.Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }
}
