import Foundation

struct HealthResponse: Codable, Equatable {
    var status: String
}

struct ChatRequest: Codable {
    var messages: [ChatMessage]
}

struct PreferenceSaveRequest: Codable {
    var key: String
    var value: String
}

struct PreferenceSaveResponse: Codable {
    var message: String
}

enum ShoppingAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL."
        case .invalidResponse:
            return "Invalid server response."
        case .server(let statusCode):
            return "Server returned status code \(statusCode)."
        }
    }
}
