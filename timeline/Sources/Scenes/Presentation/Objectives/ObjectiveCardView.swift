import SwiftUI

struct ObjectiveCardView: View {
    let objectives: [Objective]
    let onAddObjective: () -> Void
    let onSelectObjective: (Objective) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(objectives) { objective in
                    ObjectiveRingView(objective: objective) {
                        onSelectObjective(objective)
                    }
                }
                AddObjectiveCircleButton(action: onAddObjective)
            }
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .contentMargins(.horizontal, 20, for: .scrollContent)
    }
}
