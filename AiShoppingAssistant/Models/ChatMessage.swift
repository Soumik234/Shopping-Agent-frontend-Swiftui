import Foundation

struct ChatMessage: Codable, Identifiable, Equatable {
    var id = UUID()
    var role: String
    var content: String
    var products: [ParsedProduct] = []
    var createdAt = Date()
    var imageData: Data?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case products
    }

    init(
        id: UUID = UUID(),
        role: String,
        content: String,
        products: [ParsedProduct] = [],
        createdAt: Date = Date(),
        imageData: Data? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.products = products
        self.createdAt = createdAt
        self.imageData = imageData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(String.self, forKey: .role)
        content = try container.decode(String.self, forKey: .content)
        products = try container.decodeIfPresent([ParsedProduct].self, forKey: .products) ?? []
        id = UUID()
        createdAt = Date()
        imageData = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
    }
}
