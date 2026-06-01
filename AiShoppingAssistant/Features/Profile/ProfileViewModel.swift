import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    var isConnected = false
    var isChecking = false
    var errorMessage: String?

    private let api: ShoppingAPIProtocol

    init(api: ShoppingAPIProtocol) {
        self.api = api
    }

    func checkHealth() async {
        isChecking = true
        defer { isChecking = false }

        do {
            let response = try await api.health()
            isConnected = response.status.lowercased() == "ok"
            errorMessage = nil
        } catch {
            isConnected = false
            errorMessage = "Offline"
        }
    }
}
