import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SessionTrackerViewModel
    let namespace: Namespace.ID
    let onStop: () -> Void

    init(viewModel: SessionTrackerViewModel, namespace: Namespace.ID, onStop: @escaping () -> Void) {
        self.viewModel = viewModel
        self.namespace = namespace
        self.onStop = onStop
    }

    var body: some View {
        ZStack {
            gradient
                .ignoresSafeArea()

            VStack(spacing: 32) {
                TimelineView(.periodic(from: viewModel.activeSessionStartDate ?? .now, by: 1)) { timeline in
                    VStack(spacing: 12) {
                        Text("Session Running")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(viewModel.elapsedTimeString(now: timeline.date))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }

                Button {
                    viewModel.stopSession()
                    onStop()
                    dismiss()
                } label: {
                    Text("End Session")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.95))
                        )
                        .foregroundStyle(Color.black)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .matchedTransitionSource(id: SessionTrackerView.sessionTimerTransitionID, in: namespace)
        .onDisappear {
            if viewModel.isTimerRunning {
                onStop()
            }
        }
    }

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [Color.indigo.opacity(0.9), Color.purple.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
