import SwiftUI
import Observation

struct SessionTrackerView: View {
    @State private var viewModel: SessionTrackerViewModel
    private let calendar = Calendar.current
    @State private var isPresentingObjectiveSheet = false
    @State private var objectiveSheetViewModel = AddObjectiveSheetViewModel()
    @State private var isShowingArchivedObjectives = false
    @State private var showFullScreenTimer = false
    init(viewModel: SessionTrackerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        NavigationStack {
            List {
                Section {
                    objectivesSection(viewModel: bindableViewModel)
                        .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                }
                .textCase(nil)
                .listSectionSeparator(.hidden)

                Section {
                    SessionTimerView(viewModel: bindableViewModel) {
                        bindableViewModel.startSession()
                        showFullScreenTimer = true
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if bindableViewModel.isTimerRunning {
                            showFullScreenTimer = true
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 24, trailing: 20))
                    .listRowBackground(Color.clear)
                }
                .textCase(nil)
                .listSectionSeparator(.hidden)

                ActivityFeedView(
                    sections: activitySections(for: bindableViewModel),
                    emptyStateMessage: "No sessions logged yet.",
                    titleProvider: { activity in
                        bindableViewModel.label(for: activity, calendar: calendar)
                    },
                    durationFormatter: { duration in
                        bindableViewModel.formattedDuration(duration)
                    },
                    colorProvider: { activity in
                        guard let hex = bindableViewModel.colorHex(for: activity.linkedObjectiveID) else { return nil }
                        return Color(hex: hex)
                    },
                    onSelect: { activity in
                        bindableViewModel.editActivity(activity)
                    },
                    onDelete: { activity in
                        bindableViewModel.deleteActivity(activity)
                    }
                )
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Sessions")
            .navigationDestination(isPresented: $showFullScreenTimer) {
                SessionDetailView(
                    viewModel: bindableViewModel,
                    onStop: {
                        showFullScreenTimer = false
                    }
                )
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
                    objectives: bindableViewModel.activeObjectives,
                    draft: draft,
                    onSelectObjective: { objectiveID in
                        bindableViewModel.setDraftObjective(objectiveID)
                        return bindableViewModel.activityDraft?.quantityValues ?? [:]
                    },
                    onSetQuantity: { keyResultID, value in
                        bindableViewModel.setDraftQuantityValue(value, for: keyResultID)
                    },
                    onChangeNote: { bindableViewModel.setDraftNote($0) },
                    onChangeTags: { bindableViewModel.setDraftTags($0) },
                    onSave: { bindableViewModel.saveDraft() },
                    onDiscard: { bindableViewModel.discardDraft() }
                )
                .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $isPresentingObjectiveSheet) {
            AddObjectiveSheet(viewModel: objectiveSheetViewModel) { submission in
                bindableViewModel.handleObjectiveSubmission(submission)
                isPresentingObjectiveSheet = false
                objectiveSheetViewModel = AddObjectiveSheetViewModel()
            } onCancel: {
                isPresentingObjectiveSheet = false
                objectiveSheetViewModel = AddObjectiveSheetViewModel()
            } onArchive: {
                if let id = objectiveSheetViewModel.objectiveID {
                    bindableViewModel.archiveObjective(withID: id)
                }
                isPresentingObjectiveSheet = false
                objectiveSheetViewModel = AddObjectiveSheetViewModel()
            } onUnarchive: {
                if let id = objectiveSheetViewModel.objectiveID {
                    bindableViewModel.unarchiveObjective(withID: id)
                }
                isPresentingObjectiveSheet = false
                objectiveSheetViewModel = AddObjectiveSheetViewModel()
            }
        }
        .sheet(isPresented: $isShowingArchivedObjectives) {
            ArchivedObjectivesView(
                objectives: bindableViewModel.archivedObjectives,
                onClose: {
                    isShowingArchivedObjectives = false
                },
                onSelect: { objective in
                    isShowingArchivedObjectives = false
                    objectiveSheetViewModel = AddObjectiveSheetViewModel(
                        mode: .edit(objective),
                        defaultColor: ObjectiveColorProvider.color(for: objective)
                    )
                    isPresentingObjectiveSheet = true
                }
            )
        }
        .onChange(of: bindableViewModel.isTimerRunning) { _, running in
            if !running {
                showFullScreenTimer = false
            }
        }
    }

    private func objectivesSection(viewModel: SessionTrackerViewModel) -> some View {
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Objectives")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                if viewModel.hasArchivedObjectives {
                    Button {
                        isShowingArchivedObjectives = true
                    } label: {
                        Label("Archived", systemImage: "archivebox")
                            .labelStyle(TrailingIconLabelStyle())
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 4)
                }
            }
            .padding(.horizontal, 20)
            if viewModel.activeObjectives.isEmpty {
                AddObjectiveCircleButton {
                    objectiveSheetViewModel = AddObjectiveSheetViewModel()
                    isPresentingObjectiveSheet = true
                }
                .padding(.horizontal, 20)
            } else {
                ObjectiveCardView(
                    objectives: viewModel.activeObjectives,
                    onAddObjective: {
                        objectiveSheetViewModel = AddObjectiveSheetViewModel()
                        isPresentingObjectiveSheet = true
                    },
                    onSelectObjective: { objective in
                        objectiveSheetViewModel = AddObjectiveSheetViewModel(
                            mode: .edit(objective),
                            defaultColor: ObjectiveColorProvider.color(for: objective)
                        )
                        isPresentingObjectiveSheet = true
                    }
                )
            }
        }
    }

    private func activitySections(for viewModel: SessionTrackerViewModel) -> [ActivityFeedSection] {
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

private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.title
            configuration.icon
        }
    }
}
