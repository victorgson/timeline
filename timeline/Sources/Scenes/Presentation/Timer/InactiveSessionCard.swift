import SwiftUI

struct InactiveSessionCard: View {
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
