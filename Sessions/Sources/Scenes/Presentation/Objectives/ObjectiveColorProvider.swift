import SwiftUI

enum ObjectiveColorProvider {
    static func color(for objective: Objective) -> Color {
        if let hex = objective.colorHex, let color = Color(hex: hex) {
            return color
        }
        let palette: [Color] = [.pink, .orange, .mint, .blue, .purple, .teal]
        let index = abs(objective.id.hashValue) % palette.count
        return palette[index]
    }
}
