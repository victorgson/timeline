import Foundation

public protocol ActionTracking {
    var trackerDispatcher: TrackerDispatcher { get }
    func trackAction(_ trackableEvent: TrackableActionEvent)
}

public extension ActionTracking {
    func trackAction(_ trackableEvent: TrackableActionEvent) {
        trackerDispatcher.track(event: trackableEvent)
    }
}
