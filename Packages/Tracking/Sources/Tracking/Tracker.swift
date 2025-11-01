import Foundation

public protocol Tracker {
    func track(event: TrackableEvent)
}
