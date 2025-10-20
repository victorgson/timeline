import SwiftUI
import Observation

struct SessionTimerView: View {
    @Bindable var viewModel: SessionTrackerViewModel
    let onStartSession: () -> Void

    init(viewModel: SessionTrackerViewModel, onStartSession: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onStartSession = onStartSession
    }

    var body: some View {
        if viewModel.isTimerRunning, let start = viewModel.activeSessionStartDate {
            TimelineView(.periodic(from: start, by: 1)) { timeline in
                ActiveSessionCard(
                    elapsedText: viewModel.formattedTimer(timeline.date.timeIntervalSince(start)),
                    stopAction: { viewModel.stopSession(now: timeline.date) }
                )
            }
            .frame(maxWidth: .infinity)
        } else {
            InactiveSessionCard(action: onStartSession)
                .frame(maxWidth: .infinity)
        }
    }
}

private struct InactiveSessionCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "moon.zzz")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.tint)
                Text("Start Session")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                Text("Log what you’re working on")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

private struct ActiveSessionCard: View {
    let elapsedText: String
    let stopAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Session Running")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(elapsedText)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }

            Button(action: stopAction) {
                Text("End Session")
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                    )
                    .foregroundStyle(.black)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(activeGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 8)
    }

    private var activeGradient: LinearGradient {
        LinearGradient(
            colors: [Color.indigo.opacity(0.9), Color.purple.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

//#Preview("Session Timer") {
//    VStack(spacing: 24) {
//        SessionTimerView(viewModel: .preview, onStartSession: {})
//        ActiveSessionCard(elapsedText: "00:32:17", stopAction: {})
//    }
//    .padding()
//    .background(Color(.systemGroupedBackground))
//}
