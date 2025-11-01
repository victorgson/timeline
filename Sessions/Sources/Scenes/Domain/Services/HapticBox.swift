import Foundation

protocol HapticBox {
    func triggerImpact(style: DefaultHapticBox.Impact)
    func triggerNotification(_ type: DefaultHapticBox.Notification)
}
