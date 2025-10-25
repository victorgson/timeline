#if canImport(ActivityKit)
import ActivityKit
import SwiftUI
import WidgetKit

struct SessionLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionLiveActivityAttributes.self) { context in
            SessionLiveActivityLockScreenView(startDate: context.attributes.startDate)
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    SessionLiveActivityExpandedView(startDate: context.attributes.startDate)
                }
            } compactLeading: {
                SessionLiveActivityElapsedLabel(startDate: context.attributes.startDate)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .monospacedDigit()
            } compactTrailing: {
                Image(systemName: "timer")
                    .foregroundStyle(.white)
            } minimal: {
                SessionLiveActivityElapsedLabel(startDate: context.attributes.startDate)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }
        }
    }
}

private struct SessionLiveActivityLockScreenView: View {
    let startDate: Date

    var body: some View {
        SessionLiveActivityCard(startDate: startDate)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .containerBackground(for: .widget) {
                Color.clear
            }
    }
}

private struct SessionLiveActivityExpandedView: View {
    let startDate: Date

    var body: some View {
        SessionLiveActivityCard(startDate: startDate)
            .padding()
    }
}

private struct SessionLiveActivityCard: View {
    let startDate: Date

    var body: some View {
        TimelineView(.periodic(from: startDate, by: 1)) { timeline in
            let elapsed = max(0, timeline.date.timeIntervalSince(startDate))

            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Session Running")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.8))
                    Text(formattedTimer(elapsed))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }

                Label("End in app", systemImage: "app.badge.checkmark")
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal, 24)
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
    let startDate: Date

    var body: some View {
        TimelineView(.periodic(from: startDate, by: 1)) { timeline in
            Text(formattedTimer(max(0, timeline.date.timeIntervalSince(startDate))))
                .foregroundStyle(.white)
        }
    }
}

private func formattedTimer(_ interval: TimeInterval) -> String {
    let totalSeconds = Int(interval.rounded())
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

#Preview("Live Activity", as: .content, using: SessionLiveActivityAttributes(startDate: .now)) {
    SessionLiveActivityWidget()
} contentStates: {
    SessionLiveActivityAttributes.ContentState()
}
#endif
