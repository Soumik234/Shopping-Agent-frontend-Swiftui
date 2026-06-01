import Foundation
import Observation

@Observable
@MainActor
final class OrdersViewModel {
    var orders: [Order] = []
    var isLoading = false
    var errorMessage: String?

    private let api: ShoppingAPIProtocol
    private let container: AppContainer

    init(api: ShoppingAPIProtocol, container: AppContainer) {
        self.api = api
        self.container = container
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            orders = mergedOrders(remoteOrders: try await api.getOrders())
            container.orderCount = orders.count
        } catch {
            orders = container.confirmedOrders
            container.orderCount = orders.count
            if orders.isEmpty {
                errorMessage = "Orders are temporarily unavailable."
            }
        }
    }

    private func mergedOrders(remoteOrders: [Order]) -> [Order] {
        let remoteOrderIDs = Set(remoteOrders.map(\.orderId))
        let localOnlyOrders = container.confirmedOrders.filter { !remoteOrderIDs.contains($0.orderId) }

        return (localOnlyOrders + remoteOrders).sorted { first, second in
            first.orderId > second.orderId
        }
    }
}
