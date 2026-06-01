import Foundation

struct Order: Codable, Identifiable, Equatable {
    var orderId: Int
    var productId: Int
    var productName: String
    var price: Double
    var orderedAt: String
    var imageURL: URL?

    var id: Int { orderId }

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case productId = "product_id"
        case productName = "product_name"
        case price
        case orderedAt = "ordered_at"
        case imageURL = "image_url"
    }

    init(
        orderId: Int,
        productId: Int,
        productName: String,
        price: Double,
        orderedAt: String,
        imageURL: URL? = nil
    ) {
        self.orderId = orderId
        self.productId = productId
        self.productName = productName
        self.price = price
        self.orderedAt = orderedAt
        self.imageURL = imageURL
    }

    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: orderedAt) {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
        return orderedAt
    }
}
