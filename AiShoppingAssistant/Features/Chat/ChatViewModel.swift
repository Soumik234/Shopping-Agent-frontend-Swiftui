import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText = ""
    var selectedImageData: Data?
    var selectedImage: UIImage?
    var isLoading = false
    var thinkingLabel = "Searching products..."
    var errorMessage: String?
    var showOrderSuccess = false
    var lastOrderMessage = ""
    var productPendingConfirmation: ParsedProduct?

    private let api: ShoppingAPIProtocol
    private let container: AppContainer
    private var productBeingOrdered: ParsedProduct?
    private var thinkingTask: Task<Void, Never>?
    private let thinkingLabels = [
        "Searching products...",
        "Checking ratings...",
        "Finding best match...",
        "Preparing your results..."
    ]

    init(api: ShoppingAPIProtocol, container: AppContainer) {
        self.api = api
        self.container = container
    }

    func sendMessage(text overrideText: String? = nil) async {
        let text = (overrideText ?? inputText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || selectedImageData != nil else { return }
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        startThinking()

        do {
            let response: ChatMessage
            if let data = selectedImageData, overrideText == nil {
                if !text.isEmpty {
                    messages.append(ChatMessage(role: "user", content: text, imageData: data))
                } else {
                    messages.append(ChatMessage(role: "user", content: "Find products like this image.", imageData: data))
                }
                inputText = ""
                selectedImageData = nil
                selectedImage = nil
                response = try await api.uploadImage(data, mimeType: "image/jpeg")
            } else {
                let userMessage = ChatMessage(role: "user", content: text)
                messages.append(userMessage)
                inputText = ""
                response = try await api.chat(messages: messages)
            }

            stopThinking()
            messages.append(response)
            recordOrderHistoryItems(from: response.content)
            if let confirmedOrder = response.content.parsedConfirmedOrder() {
                lastOrderMessage = response.content
                container.recordConfirmedOrder(confirmedOrder.enriched(with: productBeingOrdered))
                productBeingOrdered = nil
                showOrderSuccess = true
            }
        } catch {
            stopThinking()
            productBeingOrdered = nil
            errorMessage = Self.mapError(error)
        }

        isLoading = false
    }

    private func recordOrderHistoryItems(from content: String) {
        for order in content.parsedOrderHistoryItems() {
            container.recordConfirmedOrder(order)
        }
    }

    func retryLastRequest() async {
        await sendMessage()
    }

    func clearConversation() {
        messages.removeAll()
        errorMessage = nil
        lastOrderMessage = ""
    }

    func useSuggestion(_ suggestion: String) async {
        inputText = suggestion
        await sendMessage()
    }

    func selectImageData(_ data: Data) {
        guard data.count <= 10_000_000 else {
            errorMessage = "Image is too large. Please choose another."
            return
        }
        selectedImageData = data
        selectedImage = UIImage(data: data)
        errorMessage = nil
    }

    func failImageSelection() {
        errorMessage = "Unsupported image. Use JPG or PNG."
    }

    func order(_ product: ParsedProduct) async {
        productPendingConfirmation = nil
        productBeingOrdered = product
        await sendMessage(text: "order #\(product.index)")
    }

    func parseProducts(from text: String) -> [ParsedProduct] {
        text.parsedProducts()
    }

    func products(for message: ChatMessage) -> [ParsedProduct] {
        message.products.isEmpty ? parseProducts(from: message.content) : message.products
    }

    private func startThinking() {
        thinkingTask?.cancel()
        thinkingTask = Task { [weak self] in
            guard let self else { return }
            var index = 0
            while !Task.isCancelled {
                thinkingLabel = thinkingLabels[index % thinkingLabels.count]
                index += 1
                let delay = UInt64.random(in: 800_000_000...1_200_000_000)
                try? await Task.sleep(nanoseconds: delay)
            }
        }
    }

    private func stopThinking() {
        thinkingTask?.cancel()
        thinkingTask = nil
    }

    private static func mapError(_ error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection."
            case .timedOut:
                return "Request timed out. Please try again."
            default:
                return "Network error. Please try again."
            }
        }

        if case ShoppingAPIError.server(let statusCode) = error {
            switch statusCode {
            case 400:
                return "Something went wrong. Please resend."
            case 500...599:
                return "The assistant is temporarily unavailable."
            default:
                return "The assistant is temporarily unavailable."
            }
        }

        return "The assistant is temporarily unavailable."
    }
}

private extension Order {
    func enriched(with product: ParsedProduct?) -> Order {
        guard let product else { return self }

        return Order(
            orderId: orderId,
            productId: product.id,
            productName: productName,
            price: price,
            orderedAt: orderedAt,
            imageURL: product.imageURL
        )
    }
}
