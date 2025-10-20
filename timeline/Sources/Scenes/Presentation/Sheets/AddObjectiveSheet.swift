import SwiftUI
import Observation

struct AddObjectiveSheet: View {
    @State private var viewModel: AddObjectiveSheetViewModel
    let onSave: (String, String, Double?) -> Void
    let onCancel: () -> Void

    init(
        viewModel: AddObjectiveSheetViewModel = AddObjectiveSheetViewModel(),
        onSave: @escaping (String, String, Double?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        NavigationStack {
            Form {
                Section("Objective") {
                    TextField("Title", text: $bindableViewModel.title)
                    TextField("Unit", text: $bindableViewModel.unit)
                }

                Section("Target") {
                    TextField("Target amount", text: $bindableViewModel.targetText)
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
                        onSave(viewModel.title, viewModel.unit, viewModel.parsedTarget)
                    }
                    .disabled(viewModel.isSaveDisabled)
                }
            }
        }
    }
}
