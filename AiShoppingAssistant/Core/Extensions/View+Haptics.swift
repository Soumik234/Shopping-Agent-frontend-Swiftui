import SwiftUI

extension View {
    func successHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func errorHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func warningHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func tapHaptic() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func rigidHaptic() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}
