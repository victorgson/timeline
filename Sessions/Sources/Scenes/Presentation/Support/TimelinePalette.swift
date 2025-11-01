import SwiftUI

enum TimelinePalette {
    static let accent = Color.accentColor
    static let destructive = Color(.systemRed)
    static let positive = Color(.systemGreen)
    static let caution = Color.orange

    static let sessionGradientStart = Color(
        red: 75.0 / 255.0,
        green: 168.0 / 255.0,
        blue: 1.0
    )

    static let sessionGradientEnd = Color(
        red: 122.0 / 255.0,
        green: 76.0 / 255.0,
        blue: 1.0
    )

    /// Primary gradient used across session surfaces (blue → violet)
    static let sessionGradient = LinearGradient(
        colors: [
            sessionGradientStart,
            sessionGradientEnd
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Vertical variant for compact elements like progress bars
    static let sessionGradientVertical = LinearGradient(
        colors: [
            sessionGradientStart,
            sessionGradientEnd
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
