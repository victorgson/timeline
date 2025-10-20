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
//#Preview("Session Timer") {
//    VStack(spacing: 24) {
//        SessionTimerView(viewModel: .preview, onStartSession: {})
//        ActiveSessionCard(elapsedText: "00:32:17", stopAction: {})
//    }
//    .padding()
//    .background(Color(.systemGroupedBackground))
//}
