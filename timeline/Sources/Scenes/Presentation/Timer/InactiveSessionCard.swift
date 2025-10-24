import SwiftUI

struct InactiveSessionCard: View {
    let action: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Start Session")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text("Log what you’re working on")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary.opacity(0.6))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture(perform: action)
    }
}
