import Foundation

public protocol TrackableEvent {}

public protocol TrackablePageEvent: TrackableEvent { }

public protocol TrackableActionEvent: TrackableEvent { }
