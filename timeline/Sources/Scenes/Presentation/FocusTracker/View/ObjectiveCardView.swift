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

private struct ObjectiveRingView: View {
    let objective: Objective
    private let ringLineWidth: Double = 11

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round))
                    .foregroundStyle(Color.primary.opacity(0.1))
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [color.opacity(0.85), color]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

                VStack(spacing: 2) {
                    Text(percentageText)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    Text(objective.unit)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 90, height: 90)

            VStack(spacing: 4) {
                Text(objective.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                ProgressView(value: progress)
                    .tint(color)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var progress: Double {
        min(max(objective.progress, 0), 1)
    }

    private var percentageText: String {
        "\(Int(progress * 100))%"
    }

    private var color: Color {
        ObjectiveRingPalette.color(for: objective)
    }
}

private enum ObjectiveRingPalette {
    static func color(for objective: Objective) -> Color {
        let palette: [Color] = [.pink, .orange, .mint, .blue, .purple, .teal]
        let index = abs(objective.id.hashValue) % palette.count
        return palette[index]
    }
}

//#Preview("Objectives Card") {
//    ObjectiveCardView(objectives: Array(FocusTrackerViewModel.preview.objectives.prefix(4)))
//        .padding()
//        .background(Color(.systemGroupedBackground))
//}
