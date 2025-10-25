import Foundation

protocol SessionLiveActivityControlling: AnyObject {
    func startLiveActivity(startDate: Date) async
    func endLiveActivity() async
}

final class NoopSessionLiveActivityController: SessionLiveActivityControlling {
    func startLiveActivity(startDate: Date) async {}
    func endLiveActivity() async {}
}

#if canImport(ActivityKit)
import ActivityKit

@available(iOS 16.1, *)
final class DefaultSessionLiveActivityController: SessionLiveActivityControlling {
    private typealias SessionActivity = ActivityKit.Activity<SessionLiveActivityAttributes>

    private var currentActivity: SessionActivity?

    init() {
        currentActivity = SessionActivity.activities.first
    }

    func startLiveActivity(startDate: Date) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        await endLiveActivity()
        await endDanglingActivities()

        let attributes = SessionLiveActivityAttributes(startDate: startDate)
        let contentState = SessionLiveActivityAttributes.ContentState()
        let content = ActivityContent(state: contentState, staleDate: nil)

        do {
            currentActivity = try SessionActivity.request(attributes: attributes, content: content)
        } catch {
            debugPrint("Failed to start session Live Activity: \(error)")
        }
    }

    func endLiveActivity() async {
        guard let activity = currentActivity else { return }
        let content = ActivityContent(
            state: SessionLiveActivityAttributes.ContentState(),
            staleDate: nil
        )
        await activity.end(content, dismissalPolicy: .immediate)
        currentActivity = nil
    }

    private func endDanglingActivities() async {
        let activeActivities = SessionActivity.activities
        for activity in activeActivities where activity.id != currentActivity?.id {
            let content = ActivityContent(
                state: SessionLiveActivityAttributes.ContentState(),
                staleDate: nil
            )
            await activity.end(content, dismissalPolicy: .immediate)
        }
    }
}
#endif

enum SessionLiveActivityControllerFactory {
    static func make() -> any SessionLiveActivityControlling {
#if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            return DefaultSessionLiveActivityController()
        }
#endif
        return NoopSessionLiveActivityController()
    }
}
