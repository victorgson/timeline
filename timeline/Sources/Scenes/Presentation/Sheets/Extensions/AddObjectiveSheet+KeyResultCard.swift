import SwiftUI

extension AddObjectiveSheet {
    struct KeyResultCard: View {
        let title: String
        @Binding var keyResult: AddObjectiveSheetViewModel.KeyResultForm
        let canRemove: Bool
        let onRemove: () -> Void

        var body: some View {
            SheetCardContainer(title: title) {
                VStack(alignment: .leading, spacing: 24) {
                    SheetLabeledTextField(
                        title: "Title",
                        placeholder: "Describe the outcome",
                        text: $keyResult.title,
                        axis: .vertical
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Metric Type")
                            .sheetCardLabelStyle()
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
                            timeMetricFields
                        case .quantity:
                            quantityMetricFields
                        case .none:
                            noneMetricFields
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
                        }
                        .timelineStyle(.destructive, size: .medium)
                    }
                }
            }
        }

        private var timeMetricFields: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Time Unit")
                    .sheetCardLabelStyle()
                Picker("Time Unit", selection: $keyResult.timeUnit) {
                    ForEach(KeyResult.TimeMetric.Unit.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.segmented)

                SheetLabeledTextField(
                    title: "Target",
                    placeholder: "Goal in chosen unit",
                    text: $keyResult.timeTargetText,
                    keyboardType: .decimalPad
                )

                SheetLabeledTextField(
                    title: "Logged",
                    placeholder: "Time completed so far",
                    text: $keyResult.timeCurrentText,
                    keyboardType: .decimalPad
                )
            }
        }

        private var quantityMetricFields: some View {
            VStack(alignment: .leading, spacing: 12) {
                SheetLabeledTextField(
                    title: "Unit",
                    placeholder: "e.g. articles",
                    text: $keyResult.quantityUnit,
                    autocapitalization: .never
                )

                SheetLabeledTextField(
                    title: "Target",
                    placeholder: "Goal in this unit",
                    text: $keyResult.quantityTargetText,
                    keyboardType: .decimalPad
                )

                SheetLabeledTextField(
                    title: "Current",
                    placeholder: "Current amount",
                    text: $keyResult.quantityCurrentText,
                    keyboardType: .decimalPad
                )
            }
        }

        private var noneMetricFields: some View {
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
}
