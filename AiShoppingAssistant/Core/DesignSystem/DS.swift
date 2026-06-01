import SwiftUI

enum DS {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let badge: CGFloat = 8
        static let row: CGFloat = 12
        static let button: CGFloat = 14
        static let bubble: CGFloat = 18
        static let card: CGFloat = 20
        static let input: CGFloat = 24
        static let sheet: CGFloat = 28
    }

    enum ColorToken {
        static let background = Color(.systemGroupedBackground)
        static let surface = Color(.systemBackground)
        static let primaryText = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let separator = Color(.separator)
        static let success = Color(.systemGreen)
        static let warning = Color(.systemOrange)
        static let error = Color(.systemRed)
        static let rating = Color(.systemYellow)
    }
}

extension View {
    func productCardShadow() -> some View {
        shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    func floatingInputShadow() -> some View {
        shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: -4)
    }
}
