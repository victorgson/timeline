import SwiftUI

struct ObjectivesPlaceholderCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.thickMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
                    .foregroundStyle(Color.primary.opacity(0.2))
            )
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.tint)
                    Text("Create Objective")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            )
            .frame(height: 180)
    }
}
