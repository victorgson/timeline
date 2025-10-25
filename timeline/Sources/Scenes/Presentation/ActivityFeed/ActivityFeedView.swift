import SwiftUI

struct ActivityFeedView: View {
    typealias TitleProvider = (Activity) -> String
    typealias DurationFormatter = (TimeInterval) -> String

    let sections: [ActivityFeedSection]
    let emptyStateMessage: String
    let titleProvider: TitleProvider
    let durationFormatter: DurationFormatter
    let colorProvider: ((Activity) -> Color?)?
    let onSelect: ((Activity) -> Void)?
    let onDelete: ((Activity) -> Void)?

    init(
        sections: [ActivityFeedSection],
        emptyStateMessage: String,
        titleProvider: @escaping TitleProvider,
        durationFormatter: @escaping DurationFormatter,
        colorProvider: ((Activity) -> Color?)? = nil,
        onSelect: ((Activity) -> Void)? = nil,
        onDelete: ((Activity) -> Void)? = nil
    ) {
        self.sections = sections
        self.emptyStateMessage = emptyStateMessage
        self.titleProvider = titleProvider
        self.durationFormatter = durationFormatter
        self.colorProvider = colorProvider
        self.onSelect = onSelect
        self.onDelete = onDelete
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = .autoupdatingCurrent
        return formatter
    }

    var body: some View {
        Group {
            if sections.isEmpty {
                Section {
                    emptyState
                } header: {
                    Text("Recent Sessions")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .textCase(nil)
                .listSectionSeparator(.hidden)
            } else {
                ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                    Section {
                        ForEach(section.activities) { activity in
                            ActivityRow(
                                activity: activity,
                                title: titleProvider(activity),
                                durationText: durationFormatter(activity.duration),
                                timeText: timeFormatter.string(from: activity.date),
                                onDelete: {
                                    onDelete?(activity)
                                },
                                onTap: {
                                    onSelect?(activity)
                                },
                                accentColor: colorProvider?(activity)
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    } header: {
                        header(for: index, title: section.title)
                    }
                    .textCase(nil)
                    .listSectionSeparator(.hidden)
                }
            }
        }
    }

    @ViewBuilder
    private func header(for index: Int, title: String) -> some View {
        if index == 0 {
            VStack(alignment: .leading, spacing: 4) {
                Text("Recent Sessions")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        } else {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.none)
        }
    }

    private var emptyState: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(emptyStateMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
            )
            .frame(maxWidth: .infinity, minHeight: 160)
            .padding(.vertical, 8)
            .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 12, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}
//
//#Preview("Activity Feed") {
//    let viewModel = SessionTrackerViewModel.preview
//    let calendar = Calendar.current
//    let grouped = Dictionary(grouping: viewModel.activities) { calendar.startOfDay(for: $0.date) }
//    let sections = grouped.keys.sorted(by: >).compactMap { day -> ActivityFeedSection? in
//        guard let activities = grouped[day]?.sorted(by: { $0.date > $1.date }) else { return nil }
//        let title: String
//        if calendar.isDateInToday(day) {
//            title = "Today"
//        } else if calendar.isDateInYesterday(day) {
//            title = "Yesterday"
//        } else {
//            let formatter = DateFormatter()
//            formatter.dateStyle = .medium
//            formatter.timeStyle = .none
//            title = formatter.string(from: day)
//        }
//        return ActivityFeedSection(id: day, title: title, activities: activities)
//    }
//
//    return ActivityFeedView(
//        sections: sections,
//        emptyStateMessage: "No sessions yet"
//    ) { activity in
//        viewModel.label(for: activity)
//    } durationFormatter: { duration in
//        viewModel.formattedDuration(duration)
//    }
//    .padding()
//    .background(Color(.systemGroupedBackground))
//}
