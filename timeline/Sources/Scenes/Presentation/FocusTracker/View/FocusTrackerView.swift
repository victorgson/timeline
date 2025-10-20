import SwiftUI
import Observation

struct FocusTrackerView: View {
    @State private var viewModel: FocusTrackerViewModel
    private let calendar = Calendar.current
    @State private var isPresentingObjectiveSheet = false
    @State private var showFullScreenTimer = false
    @Namespace private var focusTimerNamespace

    static let focusTimerTransitionID = "focus-timer-card"

    init(viewModel: FocusTrackerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        NavigationStack {
            List {
                Section {
                    objectivesSection(viewModel: bindableViewModel)
                        .listRowInsets(EdgeInsets(top: 24, leading: 20, bottom: 8, trailing: 20))
                        .listRowBackground(Color.clear)
                }
                .textCase(nil)
                .listSectionSeparator(.hidden)

                Section {
                    FocusTimerView(viewModel: bindableViewModel) {
                        bindableViewModel.startFocus()
                        showFullScreenTimer = true
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if bindableViewModel.isTimerRunning {
                            showFullScreenTimer = true
                        }
                    }
                    .matchedTransitionSource(id: FocusTrackerView.focusTimerTransitionID, in: focusTimerNamespace)
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 24, trailing: 20))
                    .listRowBackground(Color.clear)
                }
                .textCase(nil)
                .listSectionSeparator(.hidden)

                ActivityFeedView(
                    sections: activitySections(for: bindableViewModel),
                    emptyStateMessage: "No focus sessions yet.",
                    titleProvider: { activity in
                        bindableViewModel.label(for: activity, calendar: calendar)
                    },
                    durationFormatter: { duration in
                        bindableViewModel.formattedDuration(duration)
                    },
                    onDelete: { activity in
                        bindableViewModel.deleteActivity(activity)
                    }
                )
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Focus")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingObjectiveSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Objective")
                }
            }
            .navigationDestination(isPresented: $showFullScreenTimer) {
                FocusSessionDetailView(
                    viewModel: bindableViewModel,
                    namespace: focusTimerNamespace,
                    onStop: {
                        showFullScreenTimer = false
                    }
                )
                .navigationTransition(.zoom(sourceID: FocusTrackerView.focusTimerTransitionID, in: focusTimerNamespace))
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
                .toolbarBackground(.hidden, for: .navigationBar)
                .statusBarHidden(true)
            }
        }
        .sheet(isPresented: Binding(
            get: { bindableViewModel.activityDraft != nil },
            set: { newValue in
                if !newValue {
                    bindableViewModel.saveDraft()
                }
            }
        )) {
            if let draft = bindableViewModel.activityDraft {
                ActivityLinkSheet(
                    objectives: bindableViewModel.objectives,
                    draft: draft,
                    onSelectObjective: { bindableViewModel.setDraftObjective($0) },
                    onChangeNote: { bindableViewModel.setDraftNote($0) },
                    onChangeTags: { bindableViewModel.setDraftTags($0) },
                    onSave: { bindableViewModel.saveDraft() },
                    onDiscard: { bindableViewModel.discardDraft() }
                )
                .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $isPresentingObjectiveSheet) {
            AddObjectiveSheet { title, unit, target in
                bindableViewModel.addObjective(title: title, unit: unit, target: target)
                isPresentingObjectiveSheet = false
            } onCancel: {
                isPresentingObjectiveSheet = false
            }
        }
        .onChange(of: bindableViewModel.isTimerRunning) { running in
            if !running {
                showFullScreenTimer = false
            }
        }
    }

    private func objectivesSection(viewModel: FocusTrackerViewModel) -> some View {
        let pages = objectivePages(for: viewModel)

        let cardHeight = pages.map { objectiveCardHeight(for: $0.count) }.max() ?? objectiveCardHeight(for: 0)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Objectives")
                .font(.headline)
                .foregroundStyle(.primary)

            if pages.isEmpty {
                Button {
                    isPresentingObjectiveSheet = true
                } label: {
                    ObjectivesPlaceholderCard()
                }
                .buttonStyle(.plain)
            } else {
                TabView {
                    ForEach(pages.indices, id: \.self) { index in
                        ObjectiveCardView(objectives: pages[index])
                            .padding(.vertical, 4)
                            .padding(.horizontal, 2)
                            .frame(height: cardHeight)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: pages.count > 1 ? .automatic : .never))
                .frame(height: cardHeight)
            }
        }
    }

    private func objectiveCardHeight(for count: Int) -> CGFloat {
        if count <= 0 {
            return 200
        }
        if count <= 2 {
            return 200
        }
        return 320
    }

    private func objectivePages(for viewModel: FocusTrackerViewModel) -> [[Objective]] {
        let chunkSize = 4
        var chunks: [[Objective]] = []
        var current: [Objective] = []

        for objective in viewModel.objectives {
            current.append(objective)
            if current.count == chunkSize {
                chunks.append(current)
                current = []
            }
        }
        if !current.isEmpty {
            chunks.append(current)
        }

        return chunks
    }

    private func activitySections(for viewModel: FocusTrackerViewModel) -> [ActivityFeedSection] {
        guard !viewModel.activities.isEmpty else { return [] }

        let grouped = Dictionary(grouping: viewModel.activities) { activity -> Date in
            calendar.startOfDay(for: activity.date)
        }

        let sortedDays = grouped.keys.sorted(by: >)
        return sortedDays.compactMap { day in
            guard let activities = grouped[day]?.sorted(by: { $0.date > $1.date }) else { return nil }
            let title = title(for: day)
            return ActivityFeedSection(id: day, title: title, activities: activities)
        }
    }

    private func title(for day: Date) -> String {
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: day)
    }
}

private struct ActivityLinkSheet: View {
    let objectives: [Objective]
    @State var draft: FocusTrackerViewModel.ActivityDraft
    let onSelectObjective: (UUID?) -> Void
    let onChangeNote: (String) -> Void
    let onChangeTags: (String) -> Void
    let onSave: () -> Void
    let onDiscard: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Linked Objective") {
                    Picker("Objective", selection: selectionBinding) {
                        Text("None").tag(UUID?.none)
                        ForEach(objectives) { objective in
                            Text(objective.title).tag(UUID?.some(objective.id))
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Notes") {
                    TextField("Reflection", text: noteBinding, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section("Tags") {
                    TextField("Comma separated", text: tagsBinding)
                }

                Section {
                    Button("Save Session") {
                        onSave()
                    }
                    Button("Discard", role: .destructive) {
                        onDiscard()
                    }
                }
            }
            .navigationTitle("Link Session")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var selectionBinding: Binding<UUID?> {
        Binding<UUID?>(
            get: { draft.selectedObjectiveID },
            set: { newValue in
                draft.selectedObjectiveID = newValue
                onSelectObjective(newValue)
            }
        )
    }

    private var noteBinding: Binding<String> {
        Binding<String>(
            get: { draft.note },
            set: { newValue in
                draft.note = newValue
                onChangeNote(newValue)
            }
        )
    }

    private var tagsBinding: Binding<String> {
        Binding<String>(
            get: { draft.tagsText },
            set: { newValue in
                draft.tagsText = newValue
                onChangeTags(newValue)
            }
        )
    }
}

private struct ObjectivesPlaceholderCard: View {
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

private struct AddObjectiveSheet: View {
    @State private var title: String = ""
    @State private var unit: String = "hours"
    @State private var targetText: String = ""
    let onSave: (String, String, Double?) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Objective") {
                    TextField("Title", text: $title)
                    TextField("Unit", text: $unit)
                }

                Section("Target") {
                    TextField("Target amount", text: $targetText)
                        .keyboardType(.decimalPad)
                    Text("Use the same unit as above (e.g. hours, sessions)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Objective")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, unit, parsedTarget)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var parsedTarget: Double? {
        let trimmed = targetText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }
}

//#Preview("Focus Tracker") {
//    FocusTrackerView(viewModel: .preview)
//}
