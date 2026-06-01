import Foundation

protocol ShoppingAPIProtocol: Sendable {
    func health() async throws -> HealthResponse
    func chat(messages: [ChatMessage]) async throws -> ChatMessage
    func uploadImage(_ data: Data, mimeType: String) async throws -> ChatMessage
    func getOrders() async throws -> [Order]
    func getPreferences() async throws -> [String: String]
    func savePreference(key: String, value: String) async throws -> String
}
