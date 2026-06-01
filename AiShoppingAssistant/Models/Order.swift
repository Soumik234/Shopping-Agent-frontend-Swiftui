import Foundation

struct Order: Codable, Identifiable, Equatable {
    var orderId: Int
    var productId: Int
    var productName: String
    var price: Double
    var orderedAt: String

    var id: Int { orderId }

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case productId = "product_id"
        case productName = "product_name"
        case price
        case orderedAt = "ordered_at"
    }

    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: orderedAt) {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
        return orderedAt
    }
}
