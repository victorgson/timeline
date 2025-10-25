import SwiftUI

extension View {
    func sheetCardLabelStyle() -> some View {
        font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }

    func sheetInputFieldBackground() -> some View {
        padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(uiColor: .separator).opacity(0.25), lineWidth: 1)
            )
    }
}
