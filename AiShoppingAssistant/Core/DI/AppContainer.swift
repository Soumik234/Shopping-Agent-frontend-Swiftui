import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class AppContainer {
    static let shared = AppContainer()

    var selectedTab = 0
    var theme: AppTheme = .system
    var orderCount = 0
    var orderRefreshID = UUID()
    private(set) var confirmedOrders: [Order] = []
    var preferenceCount = 0
    var baseURL: String {
        didSet {
            UserDefaults.standard.set(baseURL, forKey: Self.baseURLKey)
            api = ShoppingAPIService(baseURL: baseURL)
        }
    }

    private(set) var api: ShoppingAPIProtocol

    private static let baseURLKey = "https://shopping-agent-tb27.onrender.com"

    private init() {
        let savedURL = UserDefaults.standard.string(forKey: Self.baseURLKey) ?? "https://shopping-agent-tb27.onrender.com"
        self.baseURL = savedURL
        self.api = ShoppingAPIService(baseURL: savedURL)
    }

    func recordConfirmedOrder(_ order: Order) {
        confirmedOrders.removeAll { $0.orderId == order.orderId }
        confirmedOrders.insert(order, at: 0)
        orderCount = confirmedOrders.count
        orderRefreshID = UUID()
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
