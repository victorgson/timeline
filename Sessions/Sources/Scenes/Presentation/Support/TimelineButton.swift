import SwiftUI

struct TimelineButtonStyle: ButtonStyle {
    enum Variant: Equatable {
        case primary
        case secondary
        case outline(Color)
        case destructive
    }

    enum Layout {
        case fill
        case hugging
        case wrap
    }

    enum Size {
        case large
        case medium
        case compact

        var verticalPadding: CGFloat {
            switch self {
            case .large:
                return 14
            case .medium:
                return 11
            case .compact:
                return 8
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .large:
                return 20
            case .medium:
                return 18
            case .compact:
                return 16
            }
        }

        var font: Font {
            switch self {
            case .large:
                return .headline.weight(.semibold)
            case .medium:
                return .subheadline.weight(.semibold)
            case .compact:
                return .footnote.weight(.semibold)
            }
        }
    }

    var variant: Variant
    var size: Size
    var layout: Layout

    init(
        _ variant: Variant = .primary,
        size: Size = .large,
        layout: Layout = .fill
    ) {
        self.variant = variant
        self.size = size
        self.layout = layout
    }

    func makeBody(configuration: Configuration) -> some View {
        TimelineButton(
            configuration: configuration,
            variant: variant,
            size: size,
            layout: layout
        )
    }
}

private struct TimelineButton: View {
    @Environment(\.isEnabled) private var isEnabled

    let configuration: ButtonStyleConfiguration
    let variant: TimelineButtonStyle.Variant
    let size: TimelineButtonStyle.Size
    let layout: TimelineButtonStyle.Layout

    private var cornerRadius: CGFloat { 18 }

    var body: some View {
        label
            .font(size.font)
            .frame(maxWidth: layout == .fill ? .infinity : nil)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(background)
            .overlay(border)
            .foregroundStyle(foreground)
            .opacity(isEnabled ? 1 : 0.55)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    @ViewBuilder
    private var label: some View {
        switch layout {
        case .wrap:
            configuration.label
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        case .hugging:
            configuration.label
                .lineLimit(1)
        case .fill:
            configuration.label
        }
    }

    @ViewBuilder
    private var background: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        switch variant {
        case .primary:
            shape
                .fill(positiveColor.opacity(0.22))
                .overlay(
                    shape
                        .fill(positiveColor.opacity(configuration.isPressed ? 0.18 : 0.1))
                )
        case .secondary:
            shape
                .fill(TimelinePalette.accent.opacity(0.16))
        case .outline(let color):
            shape
                .fill(color.opacity(0.08))
        case .destructive:
            shape
                .fill(destructiveColor.opacity(0.18))
        }
    }

    @ViewBuilder
    private var border: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        switch variant {
        case .primary:
            shape
                .stroke(positiveColor.opacity(0.45), lineWidth: 1.2)
        case .secondary:
            shape
                .stroke(TimelinePalette.accent.opacity(0.35), lineWidth: 1)
        case .outline(let color):
            shape
                .stroke(color.opacity(0.55), lineWidth: 1.3)
        case .destructive:
            shape
                .stroke(destructiveColor.opacity(0.45), lineWidth: 1.2)
        }
    }

    private var foreground: Color {
        switch variant {
        case .primary:
            return positiveColor
        case .secondary:
            return TimelinePalette.accent
        case .outline(let color):
            return color
        case .destructive:
            return destructiveColor
        }
    }

    private var destructiveColor: Color {
        TimelinePalette.destructive
    }

    private var positiveColor: Color {
        TimelinePalette.positive
    }
}

extension Button {
    func timelineStyle(
        _ variant: TimelineButtonStyle.Variant = .primary,
        size: TimelineButtonStyle.Size = .large,
        layout: TimelineButtonStyle.Layout = .fill
    ) -> some View {
        buttonStyle(
            TimelineButtonStyle(
                variant,
                size: size,
                layout: layout
            )
        )
    }
}
