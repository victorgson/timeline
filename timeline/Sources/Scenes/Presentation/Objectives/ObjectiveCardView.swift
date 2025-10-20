import SwiftUI

struct ObjectiveCardView: View {
    let objectives: [Objective]
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(objectives) { objective in
                        ObjectiveRingView(objective: objective)
                    }
                }
                    .padding(24)
            )
            .frame(maxWidth: .infinity)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
//#Preview("Objectives Card") {
//    ObjectiveCardView(objectives: Array(SessionTrackerViewModel.preview.objectives.prefix(4)))
//        .padding()
//        .background(Color(.systemGroupedBackground))
//}
