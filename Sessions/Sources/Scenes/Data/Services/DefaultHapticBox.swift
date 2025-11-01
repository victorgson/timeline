import UIKit

@MainActor
final class DefaultHapticBox: HapticBox {
    private let impactGenerators: [Impact: UIImpactFeedbackGenerator]
    private let notificationGenerator: UINotificationFeedbackGenerator

    init() {
        impactGenerators = [
            .light: UIImpactFeedbackGenerator(style: .light),
            .medium: UIImpactFeedbackGenerator(style: .medium),
            .heavy: UIImpactFeedbackGenerator(style: .heavy)
        ]
        notificationGenerator = UINotificationFeedbackGenerator()
    }

    func triggerImpact(style: DefaultHapticBox.Impact) {
        guard let generator = impactGenerators[style] else { return }
        generator.prepare()
        generator.impactOccurred()
    }

    func triggerNotification(_ type: DefaultHapticBox.Notification) {
        notificationGenerator.prepare()
        switch type {
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        }
    }
}
