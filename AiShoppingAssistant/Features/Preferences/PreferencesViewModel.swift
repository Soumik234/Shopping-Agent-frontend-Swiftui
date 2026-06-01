import Foundation
import Observation

@Observable
@MainActor
final class PreferencesViewModel {
    var organic = false
    var maxPrice = 50.0
    var category = "honey"
    var minRating = "Any"
    var customPreferences: [PreferenceItem] = []
    var isLoading = false
    var errorMessage: String?

    let categories = ["honey", "oil", "nuts", "grains", "tea", "snacks"]
    let ratingOptions = ["Any", "3.5", "4.0", "4.5"]

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
            let preferences = try await api.getPreferences()
            apply(preferences)
            container.preferenceCount = preferences.count
        } catch {
            errorMessage = "Preferences are temporarily unavailable."
        }
    }

    func saveBuiltIn(key: String) async {
        let value: String
        switch key {
        case "organic": value = organic ? "true" : "false"
        case "max_price": value = Int(maxPrice).description
        case "category": value = category
        case "min_rating": value = minRating
        default: return
        }
        await save(key: key, value: value)
    }

    func addCustomPreference() {
        customPreferences.append(PreferenceItem(key: "", value: ""))
    }

    func deleteCustomPreference(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            customPreferences.remove(at: index)
        }
    }

    func saveCustomPreference(_ item: PreferenceItem) async {
        let key = item.key.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = item.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, !value.isEmpty else { return }
        await save(key: key, value: value)
    }

    private func save(key: String, value: String) async {
        do {
            _ = try await api.savePreference(key: key, value: value)
            errorMessage = nil
        } catch {
            errorMessage = "Preference could not be saved."
        }
    }

    private func apply(_ preferences: [String: String]) {
        organic = preferences["organic"]?.lowercased() == "true"
        if let maxPriceValue = preferences["max_price"], let value = Double(maxPriceValue) {
            maxPrice = min(max(value, 1), 100)
        }
        category = preferences["category"] ?? "honey"
        minRating = preferences["min_rating"] ?? "Any"

        let builtIn = Set(["organic", "max_price", "category", "min_rating"])
        customPreferences = preferences
            .filter { !builtIn.contains($0.key) }
            .map { PreferenceItem(key: $0.key, value: $0.value) }
            .sorted { $0.key < $1.key }
    }
}

struct PreferenceItem: Identifiable, Equatable {
    var id = UUID()
    var key: String
    var value: String
}
