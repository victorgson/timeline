import SwiftUI
import Observation

struct SessionTrackerView: View {
    @State private var viewModel: SessionTrackerViewModel
    private let calendar = Calendar.current
    @State private var isPresentingObjectiveSheet = false
    @State private var objectiveSheetViewModel = AddObjectiveSheetViewModel()
    @State private var showFullScreenTimer = false
    @Namespace private var sessionTimerNamespace
    
    static let sessionTimerTransitionID = "session-timer-card"
    
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
                    .matchedTransitionSource(id: SessionTrackerView.sessionTimerTransitionID, in: sessionTimerNamespace)
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
                    namespace: sessionTimerNamespace,
                    onStop: {
                        showFullScreenTimer = false
                    }
                )
                .navigationTransition(.zoom(sourceID: SessionTrackerView.sessionTimerTransitionID, in: sessionTimerNamespace))
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
                    onSelectObjective: { objectiveID in
                        bindableViewModel.setDraftObjective(objectiveID)
                        return bindableViewModel.activityDraft?.quantityValues ?? [:]
                    },
                    onToggleTimeKeyResult: { keyResultID, isSelected in
                        bindableViewModel.toggleDraftTimeKeyResult(keyResultID, isSelected: isSelected)
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
            }
        }
        .onChange(of: bindableViewModel.isTimerRunning) { running in
            if !running {
                showFullScreenTimer = false
            }
        }
    }
    
    private func objectivesSection(viewModel: SessionTrackerViewModel) -> some View {
        return VStack(alignment: .leading, spacing: 12) {
            Text("Objectives")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)

            if viewModel.objectives.isEmpty {
                AddObjectiveCircleButton {
                    objectiveSheetViewModel = AddObjectiveSheetViewModel()
                    isPresentingObjectiveSheet = true
                }
                .padding(.horizontal, 20)
            } else {
                ObjectiveCardView(
                    objectives: viewModel.objectives,
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
//#Preview("Session Tracker") {
//    SessionTrackerView(viewModel: .preview)
//}
