#if canImport(ActivityKit)
import ActivityKit
import SwiftUI
import WidgetKit

struct SessionLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionLiveActivityAttributes.self) { context in
            SessionLiveActivityLockScreenView(timerRange: context.state.timerRange)
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(.white)
//                .contentMarginsDisabled()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    SessionLiveActivityExpandedView(timerRange: context.state.timerRange)
                }
            } compactLeading: {
                SessionLiveActivityElapsedLabel(timerRange: context.state.timerRange)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
            } compactTrailing: {
                Image(systemName: "timer")
                    .foregroundStyle(.white)
            } minimal: {
                SessionLiveActivityElapsedLabel(timerRange: context.state.timerRange)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
            }
        }
    }
}

private struct SessionLiveActivityLockScreenView: View {
    let timerRange: ClosedRange<Date>

    var body: some View {
        SessionLiveActivityCard(timerRange: timerRange)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(for: .widget) {
                Color.clear
            }
    }
}

private struct SessionLiveActivityExpandedView: View {
    let timerRange: ClosedRange<Date>

    var body: some View {
        SessionLiveActivityCard(timerRange: timerRange)
            .padding(.horizontal)
            .padding(.vertical, 12)
    }
}

private struct SessionLiveActivityCard: View {
    let timerRange: ClosedRange<Date>

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Session Running")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.8))
                LiveActivityTimerLabel(timerRange: timerRange)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(activeGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
    }

    private var activeGradient: LinearGradient {
        LinearGradient(
            colors: [Color.indigo.opacity(0.9), Color.purple.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct SessionLiveActivityElapsedLabel: View {
    let timerRange: ClosedRange<Date>

    var body: some View {
        LiveActivityTimerLabel(timerRange: timerRange)
            .foregroundStyle(.white)
    }
}

private struct LiveActivityTimerLabel: View {
    let timerRange: ClosedRange<Date>

    var body: some View {
        Text(timerInterval: timerRange, countsDown: false)
            .monospacedDigit()
            .contentTransition(.numericText())
    }
}

#Preview("Live Activity", as: .content, using: SessionLiveActivityAttributes(startDate: .now)) {
    SessionLiveActivityWidget()
} contentStates: {
    SessionLiveActivityAttributes.ContentState(
        timerRange: Date.now.addingTimeInterval(-90)...Date.now.addingTimeInterval(60)
    )
}
#endif
