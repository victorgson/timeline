import SwiftUI
import Observation

struct ActivityLinkSheet: View {
    let objectives: [Objective]
    @State private var viewModel: ActivityLinkSheetViewModel
    let onSelectObjective: (UUID?) -> Void
    let onChangeNote: (String) -> Void
    let onChangeTags: (String) -> Void
    let onSave: () -> Void
    let onDiscard: () -> Void

    init(
        objectives: [Objective],
        draft: SessionTrackerViewModel.ActivityDraft,
        onSelectObjective: @escaping (UUID?) -> Void,
        onChangeNote: @escaping (String) -> Void,
        onChangeTags: @escaping (String) -> Void,
        onSave: @escaping () -> Void,
        onDiscard: @escaping () -> Void
    ) {
        self.objectives = objectives
        _viewModel = State(initialValue: ActivityLinkSheetViewModel(draft: draft))
        self.onSelectObjective = onSelectObjective
        self.onChangeNote = onChangeNote
        self.onChangeTags = onChangeTags
        self.onSave = onSave
        self.onDiscard = onDiscard
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        NavigationStack {
            Form {
                Section("Linked Objective") {
                    Picker("Objective", selection: $bindableViewModel.selectedObjectiveID) {
                        Text("None").tag(UUID?.none)
                        ForEach(objectives) { objective in
                            Text(objective.title).tag(UUID?.some(objective.id))
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Notes") {
                    TextField("Reflection", text: $bindableViewModel.note, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section("Tags") {
                    TextField("Comma separated", text: $bindableViewModel.tagsText)
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
        .onChange(of: viewModel.selectedObjectiveID) { newValue in
            onSelectObjective(newValue)
        }
        .onChange(of: viewModel.note) { newValue in
            onChangeNote(newValue)
        }
        .onChange(of: viewModel.tagsText) { newValue in
            onChangeTags(newValue)
        }
    }
}
