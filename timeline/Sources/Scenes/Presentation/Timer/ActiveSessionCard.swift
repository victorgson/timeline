import SwiftUI

struct ActiveSessionCard: View {
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
