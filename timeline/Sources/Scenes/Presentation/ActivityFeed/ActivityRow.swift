import SwiftUI

struct ActivityRow: View {
    let activity: Activity
    let title: String
    let durationText: String
    let timeText: String
    let onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text(durationText)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(timeText)
                .font(.caption)
                .foregroundStyle(.tertiary)

            if let note = activity.note, !note.isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
            }

            if !activity.tags.isEmpty {
                TagsView(tags: activity.tags)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
