import Observation
import SwiftUI
import UIKit

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
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if viewModel.isEditing, viewModel.isCompleted, let completedDateText = viewModel.completedDateText {
                        SheetCardContainer {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color.accentColor)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Objective Completed")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("Completed on \(completedDateText)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }

                    SheetCardContainer(title: "Objective") {
                        VStack(alignment: .leading, spacing: 20) {
                            SheetLabeledTextField(
                                title: "Title",
                                placeholder: "Ship the quarterly roadmap",
                                text: $bindableViewModel.title,
                                axis: .vertical,
                                autocapitalization: .words
                            )

                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $bindableViewModel.isEndDateEnabled.animation()) {
                                    Text("Set End Date")
                                        .sheetCardLabelStyle()
                                }
                                .tint(.accentColor)

                                Text("Track a deadline for this objective.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)

                                if bindableViewModel.isEndDateEnabled {
                                    DatePicker(
                                        "Objective End Date",
                                        selection: $bindableViewModel.endDate,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                }
                            }
                        }
                    }

                    SheetCardContainer(title: "Appearance") {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Color")
                                    .sheetCardLabelStyle()
                                Text("Choose a tint for this objective.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            ColorPicker("Objective Color", selection: $bindableViewModel.color, supportsOpacity: false)
                                .labelsHidden()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(uiColor: .separator).opacity(0.4), lineWidth: 1)
                                )
                        }
                        .padding(.vertical, 4)
                    }

                    ForEach(bindableViewModel.keyResults) { keyResult in
                        AddObjectiveSheet.KeyResultCard(
                            title: viewModel.sectionTitle(forKeyResult: keyResult.id),
                            keyResult: Binding(
                                get: {
                                    bindableViewModel.keyResults.first(where: { $0.id == keyResult.id }) ?? keyResult
                                },
                                set: { newValue in
                                    bindableViewModel.updateKeyResult(newValue)
                                }
                            ),
                            canRemove: bindableViewModel.keyResults.count > 1,
                            onRemove: { viewModel.removeKeyResult(id: keyResult.id) }
                        )
                    }

                    Button {
                        viewModel.addKeyResult()
                    } label: {
                        Label("Add Key Result", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.accentColor.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
                    )
                    .foregroundColor(.accentColor)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
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
