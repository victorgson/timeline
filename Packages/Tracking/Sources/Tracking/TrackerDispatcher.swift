import Foundation

public protocol TrackerDispatcher {
    var trackers: [Tracker] { get set }
    
    func track(event: TrackableEvent)
}

public final class DefaultTrackerDispatcher: TrackerDispatcher {
    
    public var trackers: [Tracker]
    
    public init(trackers: [Tracker]) {
        self.trackers = trackers
    }
    
    public func track(event: TrackableEvent) {
        for tracker in trackers {
            tracker.track(event: event)
        }
    }
    
}
