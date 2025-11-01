import Foundation
import SwiftUI

public protocol PageTracking {
    var trackerDispatcher: TrackerDispatcher { get }
    var pageViewEvent: TrackablePageEvent { get }
    func trackPageView()
    func trackPageView(_ trackableEvent: TrackablePageEvent)
}

public extension PageTracking {
    func trackPageView() {
        trackPageView(pageViewEvent)
    }
    
    func trackPageView(_ trackableEvent: TrackablePageEvent) {
        trackerDispatcher.track(event: trackableEvent)
    }
}

public protocol PageTrackingView {
    associatedtype T: PageTracking
    var viewModel: T { get }
    func trackPageView()
}

public extension PageTrackingView where Self: View {
    func trackPageView() {
        viewModel.trackPageView()
    }
}
