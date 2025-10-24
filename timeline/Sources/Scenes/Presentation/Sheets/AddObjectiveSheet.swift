import SwiftUI
import Observation

struct AddObjectiveSheet: View {
    @State private var viewModel: AddObjectiveSheetViewModel
    let onSave: (ObjectiveFormSubmission) -> Void
    let onCancel: () -> Void

    init(
        viewModel: AddObjectiveSheetViewModel = AddObjectiveSheetViewModel(),
        onSave: @escaping (ObjectiveFormSubmission) -> Void,
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
                        .textInputAutocapitalization(.words)
                }

                Section("Appearance") {
                    HStack {
                        Text("Color")
                        Spacer()
                        ColorPicker("Objective Color", selection: $bindableViewModel.color, supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                            )
                    }
                }

                Section("Key Results") {
                    ForEach($bindableViewModel.keyResults) { $keyResult in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Key result title", text: $keyResult.title, axis: .vertical)
                                .lineLimit(2, reservesSpace: true)

                            Toggle("Track time", isOn: $keyResult.includeTime.animation())
                                .toggleStyle(.switch)
                            if keyResult.includeTime {
                                Picker("Unit", selection: $keyResult.timeUnit) {
                                    ForEach(KeyResult.TimeMetric.Unit.allCases, id: \.self) { unit in
                                        Text(unit.displayName).tag(unit)
                                    }
                                }
                                TextField("Target", text: $keyResult.timeTargetText)
                                    .keyboardType(.decimalPad)
                                TextField("Logged so far", text: $keyResult.timeCurrentText)
                                    .keyboardType(.decimalPad)
                                    .foregroundStyle(.secondary)
                            }

                            Toggle("Track quantity", isOn: $keyResult.includeQuantity.animation())
                                .toggleStyle(.switch)
                                .padding(.top, 4)
                            if keyResult.includeQuantity {
                                TextField("Unit", text: $keyResult.quantityUnit)
                                    .textInputAutocapitalization(.never)
                                TextField("Target", text: $keyResult.quantityTargetText)
                                    .keyboardType(.decimalPad)
                                TextField("Current value", text: $keyResult.quantityCurrentText)
                                    .keyboardType(.decimalPad)
                                    .foregroundStyle(.secondary)
                            }

                            if viewModel.keyResults.count > 1 {
                                Button(role: .destructive) {
                                    viewModel.removeKeyResult(id: keyResult.id)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                                .buttonStyle(.borderless)
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Button {
                        viewModel.addKeyResult()
                    } label: {
                        Label("Add Key Result", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Objective" : "New Objective")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(viewModel.makeSubmission())
                    }
                    .disabled(viewModel.isSaveDisabled)
                }
            }
        }
    }
}
