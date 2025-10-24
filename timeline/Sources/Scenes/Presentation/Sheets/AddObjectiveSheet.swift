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
                    CardContainer(title: "Objective") {
                        LabeledTextField(
                            title: "Title",
                            placeholder: "Ship the quarterly roadmap",
                            text: $bindableViewModel.title,
                            axis: .vertical,
                            autocapitalization: .words
                        )
                    }

                    CardContainer(title: "Appearance") {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Color")
                                    .cardLabelStyle()
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
                        KeyResultCard(
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

private struct CardContainer<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let title, !title.isEmpty {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}

private struct LabeledTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .cardLabelStyle()
            TextField(placeholder, text: $text, axis: axis)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(autocapitalization)
                .keyboardType(keyboardType)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(uiColor: .systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(uiColor: .separator).opacity(0.25), lineWidth: 1)
                )
        }
    }
}

private struct KeyResultCard: View {
    let title: String
    @Binding var keyResult: AddObjectiveSheetViewModel.KeyResultForm
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        CardContainer(title: title) {
            VStack(alignment: .leading, spacing: 24) {
                LabeledTextField(
                    title: "Title",
                    placeholder: "Describe the outcome",
                    text: $keyResult.title,
                    axis: .vertical
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Metric Type")
                        .cardLabelStyle()
                    Picker("Metric Type", selection: $keyResult.metricType) {
                        ForEach(AddObjectiveSheetViewModel.KeyResultForm.MetricType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .animation(.easeInOut(duration: 0.2), value: keyResult.metricType)

                Group {
                    switch keyResult.metricType {
                    case .time:
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time Unit")
                                .cardLabelStyle()
                            Picker("Time Unit", selection: $keyResult.timeUnit) {
                                ForEach(KeyResult.TimeMetric.Unit.allCases, id: \.self) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                            .pickerStyle(.segmented)

                            LabeledTextField(
                                title: "Target",
                                placeholder: "Goal in chosen unit",
                                text: $keyResult.timeTargetText,
                                keyboardType: .decimalPad
                            )

                            LabeledTextField(
                                title: "Logged",
                                placeholder: "Time completed so far",
                                text: $keyResult.timeCurrentText,
                                keyboardType: .decimalPad
                            )
                        }
                    case .quantity:
                        VStack(alignment: .leading, spacing: 12) {
                            LabeledTextField(
                                title: "Unit",
                                placeholder: "e.g. articles",
                                text: $keyResult.quantityUnit,
                                autocapitalization: .never
                            )

                            LabeledTextField(
                                title: "Target",
                                placeholder: "Goal in this unit",
                                text: $keyResult.quantityTargetText,
                                keyboardType: .decimalPad
                            )

                            LabeledTextField(
                                title: "Current",
                                placeholder: "Current amount",
                                text: $keyResult.quantityCurrentText,
                                keyboardType: .decimalPad
                            )
                        }
                    case .none:
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No Tracking")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("Choose a metric type to track progress on this key result.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if canRemove {
                    Divider()
                    Button(role: .destructive) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            onRemove()
                        }
                    } label: {
                        Label("Remove Key Result", systemImage: "trash")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
            }
        }
    }
}

private extension View {
    func cardLabelStyle() -> some View {
        font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}
