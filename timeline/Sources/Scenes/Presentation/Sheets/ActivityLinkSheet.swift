import SwiftUI
import Observation

struct ActivityLinkSheet: View {
    let objectives: [Objective]
    @State private var viewModel: ActivityLinkSheetViewModel
    let onSelectObjective: (UUID?) -> [UUID: Double]
    let onToggleTimeKeyResult: (UUID, Bool) -> Void
    let onSetQuantity: (UUID, Double) -> Void
    let onChangeNote: (String) -> Void
    let onChangeTags: (String) -> Void
    let onSave: () -> Void
    let onDiscard: () -> Void

    init(
        objectives: [Objective],
        draft: SessionTrackerViewModel.ActivityDraft,
        onSelectObjective: @escaping (UUID?) -> [UUID: Double],
        onToggleTimeKeyResult: @escaping (UUID, Bool) -> Void,
        onSetQuantity: @escaping (UUID, Double) -> Void,
        onChangeNote: @escaping (String) -> Void,
        onChangeTags: @escaping (String) -> Void,
        onSave: @escaping () -> Void,
        onDiscard: @escaping () -> Void
    ) {
        self.objectives = objectives
        _viewModel = State(initialValue: ActivityLinkSheetViewModel(draft: draft))
        self.onSelectObjective = onSelectObjective
        self.onToggleTimeKeyResult = onToggleTimeKeyResult
        self.onSetQuantity = onSetQuantity
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

                if let selectedObjective = objective(for: viewModel.selectedObjectiveID) {
                    keyResultsSection(for: selectedObjective)
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
            let quantityDefaults = onSelectObjective(newValue)
            viewModel.updateQuantityValues(quantityDefaults)
            viewModel.selectedTimeKeyResultIDs = []
        }
        .onChange(of: viewModel.note) { newValue in
            onChangeNote(newValue)
        }
        .onChange(of: viewModel.tagsText) { newValue in
            onChangeTags(newValue)
        }
    }

    private func keyResultsSection(for objective: Objective) -> some View {
        Section("Key Results") {
            if objective.keyResults.isEmpty {
                Text("No key results configured yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }

            ForEach(objective.keyResults) { keyResult in
                VStack(alignment: .leading, spacing: 12) {
                    Text(keyResult.title)
                        .font(.headline)

                    if let timeMetric = keyResult.timeMetric {
                        Toggle(isOn: Binding(
                            get: { viewModel.selectedTimeKeyResultIDs.contains(keyResult.id) },
                            set: { isOn in
                                viewModel.setTimeSelection(isOn, for: keyResult.id)
                                onToggleTimeKeyResult(keyResult.id, isOn)
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Time")
                                    .font(.subheadline.weight(.semibold))
                                Text(timeDescription(for: timeMetric))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .toggleStyle(.switch)
                    }

                    if let quantityMetric = keyResult.quantityMetric {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Quantity")
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(quantityValueDescription(for: keyResult))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Slider(
                                value: Binding(
                                    get: {
                                        viewModel.quantityValues[keyResult.id] ?? quantityMetric.current
                                    },
                                    set: { newValue in
                                        viewModel.setQuantityValue(newValue, for: keyResult.id)
                                        onSetQuantity(keyResult.id, newValue)
                                    }
                                ),
                                in: 0...sliderUpperBound(for: keyResult, metric: quantityMetric)
                            )
                            Text(quantityUnitDescription(for: quantityMetric))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }

    private func objective(for id: UUID?) -> Objective? {
        guard let id else { return nil }
        return objectives.first(where: { $0.id == id })
    }

    private func timeDescription(for metric: KeyResult.TimeMetric) -> String {
        let logged = formatted(value: metric.logged)
        let target = formatted(value: metric.target)
        return "\(logged) / \(target) \(metric.unit.displayName.lowercased())"
    }

    private func quantityValueDescription(for keyResult: KeyResult) -> String {
        guard let quantity = keyResult.quantityMetric else { return "" }
        let value = viewModel.quantityValues[keyResult.id] ?? quantity.current
        let formattedValue = formatted(value: value)
        let formattedTarget = formatted(value: quantity.target)
        return "\(formattedValue) / \(formattedTarget) \(quantity.unit)"
    }

    private func quantityUnitDescription(for metric: KeyResult.QuantityMetric) -> String {
        "Drag to update in \(metric.unit)"
    }

    private func sliderUpperBound(for keyResult: KeyResult, metric: KeyResult.QuantityMetric) -> Double {
        let currentValue = viewModel.quantityValues[keyResult.id] ?? metric.current
        let base = max(metric.target, currentValue)
        let minimum = metric.target > 0 ? metric.target : 1
        return max(base * 1.5, minimum * 2)
    }

    private func formatted(value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }
}
