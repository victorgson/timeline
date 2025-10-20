import SwiftUI
import Observation

struct SessionTrackerView: View {
    @State private var viewModel: SessionTrackerViewModel
    private let calendar = Calendar.current
    @State private var isPresentingObjectiveSheet = false
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
                        .listRowInsets(EdgeInsets(top: 24, leading: 20, bottom: 8, trailing: 20))
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
                    onDelete: { activity in
                        bindableViewModel.deleteActivity(activity)
                    }
                )
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Sessions")
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
    
    private func objectivesSection(viewModel: SessionTrackerViewModel) -> some View {
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
    
    private func objectivePages(for viewModel: SessionTrackerViewModel) -> [[Objective]] {
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
