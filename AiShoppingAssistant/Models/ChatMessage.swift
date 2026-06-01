import Foundation

struct ChatMessage: Codable, Identifiable, Equatable {
    var id = UUID()
    var role: String
    var content: String
    var createdAt = Date()

    enum CodingKeys: String, CodingKey {
        case role
        case content
    }

    init(id: UUID = UUID(), role: String, content: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
}
