import Foundation

final class ShoppingAPIService: ShoppingAPIProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(baseURL: String = "http://192.168.0.241:8000") {
        self.baseURL = URL(string: baseURL) ?? URL(string: "http://192.168.0.241:8000")!
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    func health() async throws -> HealthResponse {
        try await request(path: "health", method: "GET", responseType: HealthResponse.self)
    }

    func chat(messages: [ChatMessage]) async throws -> ChatMessage {
        try await request(
            path: "chat",
            method: "POST",
            body: ChatRequest(messages: messages),
            responseType: ChatMessage.self
        )
    }

    func uploadImage(_ data: Data, mimeType: String) async throws -> ChatMessage {
        let boundary = UUID().uuidString
        var request = try makeRequest(path: "upload-image")
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = multipartBody(data: data, mimeType: mimeType, boundary: boundary)
        return try await perform(request, responseType: ChatMessage.self)
    }

    func getProducts() async throws -> [StoreProduct] {
        try await request(path: "products", method: "GET", responseType: [StoreProduct].self)
    }

    func getOrders() async throws -> [Order] {
        try await request(path: "orders", method: "GET", responseType: [Order].self)
    }

    func getPreferences() async throws -> [String: String] {
        try await request(path: "preferences", method: "GET", responseType: [String: String].self)
    }

    func savePreference(key: String, value: String) async throws -> String {
        let response = try await request(
            path: "preferences",
            method: "POST",
            body: PreferenceSaveRequest(key: key, value: value),
            responseType: PreferenceSaveResponse.self
        )
        return response.message
    }

    private func request<Response: Decodable>(
        path: String,
        method: String,
        responseType: Response.Type
    ) async throws -> Response {
        var request = try makeRequest(path: path)
        request.httpMethod = method
        return try await perform(request, responseType: responseType)
    }

    private func request<Body: Encodable, Response: Decodable>(
        path: String,
        method: String,
        body: Body,
        responseType: Response.Type
    ) async throws -> Response {
        var request = try makeRequest(path: path)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return try await perform(request, responseType: responseType)
    }

    private func makeRequest(path: String) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL)?.absoluteURL else {
            throw ShoppingAPIError.invalidURL
        }
        return URLRequest(url: url)
    }

    private func perform<Response: Decodable>(_ request: URLRequest, responseType: Response.Type) async throws -> Response {
        log("➡️ \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown URL")")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            log("❌ Invalid response for \(request.url?.absoluteString ?? "unknown URL")")
            throw ShoppingAPIError.invalidResponse
        }

        log("⬅️ \(httpResponse.statusCode) \(request.url?.absoluteString ?? "unknown URL")")
        logResponseBody(data)

        guard 200..<300 ~= httpResponse.statusCode else {
            log("❌ Server error \(httpResponse.statusCode)")
            throw ShoppingAPIError.server(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            log("❌ Decode error for \(Response.self): \(error)")
            throw error
        }
    }

    private func log(_ message: String) {
        #if DEBUG
        print("[ShoppingAPI] \(message)")
        #endif
    }

    private func logResponseBody(_ data: Data) {
        #if DEBUG
        let maxLength = 4_096
        let visibleData = data.prefix(maxLength)
        let body = String(data: visibleData, encoding: .utf8) ?? "<non-UTF8 response: \(data.count) bytes>"
        let suffix = data.count > maxLength ? "\n… truncated \(data.count - maxLength) bytes" : ""
        log("📦 Response body:\n\(body)\(suffix)")
        #endif
    }

    private func multipartBody(data: Data, mimeType: String, boundary: String) -> Data {
        var body = Data()
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n--\(boundary)--\r\n")
        return body
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
