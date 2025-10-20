import SwiftUI

struct AddObjectiveCircleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.clear)
                    Circle()
                        .stroke(
                            style: StrokeStyle(lineWidth: 2, dash: [6, 6])
                        )
                        .foregroundStyle(Color.white.opacity(0.7))
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 88, height: 88)

                Text("New Objective")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 96)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Create Objective")
    }
}
