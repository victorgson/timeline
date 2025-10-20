import SwiftUI

struct ActivityRow: View {
    let activity: Activity
    let title: String
    let durationText: String
    let timeText: String
    let onDelete: (() -> Void)?
    let onTap: (() -> Void)?
    let accentColor: Color?

    init(
        activity: Activity,
        title: String,
        durationText: String,
        timeText: String,
        onDelete: (() -> Void)? = nil,
        onTap: (() -> Void)? = nil,
        accentColor: Color? = nil
    ) {
        self.activity = activity
        self.title = title
        self.durationText = durationText
        self.timeText = timeText
        self.onDelete = onDelete
        self.onTap = onTap
        self.accentColor = accentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if let accentColor {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 10, height: 10)
                        .alignmentGuide(.firstTextBaseline) { dimensions in
                            dimensions[VerticalAlignment.center]
                        }
                }

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
        .onTapGesture {
            onTap?()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
