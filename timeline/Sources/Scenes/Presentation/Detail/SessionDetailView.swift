import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SessionTrackerViewModel
    let onStop: () -> Void

    init(viewModel: SessionTrackerViewModel, onStop: @escaping () -> Void) {
        self.viewModel = viewModel
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
                            .foregroundStyle(Color.white.opacity(0.8))
                        Text(viewModel.elapsedTimeString(now: timeline.date))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }

                Button {
                    let stopTime = Date()
                    onStop()
                    dismiss()
                    DispatchQueue.main.async {
                        viewModel.stopSession(now: stopTime)
                    }
                } label: {
                    Text("End Session")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.9), lineWidth: 1.5)
                        )
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .ignoresSafeArea()
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
