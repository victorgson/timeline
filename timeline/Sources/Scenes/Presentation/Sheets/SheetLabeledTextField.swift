import SwiftUI

struct SheetLabeledTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .sheetCardLabelStyle()
            TextField(placeholder, text: $text, axis: axis)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(autocapitalization)
                .keyboardType(keyboardType)
                .sheetInputFieldBackground()
        }
    }
}
