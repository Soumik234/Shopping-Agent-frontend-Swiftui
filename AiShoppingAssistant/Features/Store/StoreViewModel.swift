import Foundation
import Observation

@Observable
@MainActor
final class StoreViewModel {
    var products: [StoreProduct] = []
    var selectedCategory = "All"
    var searchText = ""
    var isLoading = false
    var errorMessage: String?

    private let api: ShoppingAPIProtocol

    init(api: ShoppingAPIProtocol) {
        self.api = api
    }

    var categories: [String] {
        let productCategories = Set(products.map(\.displayCategory))
        return ["All"] + productCategories.sorted()
    }

    var filteredProducts: [StoreProduct] {
        products.filter { product in
            let matchesCategory = selectedCategory == "All" || product.displayCategory == selectedCategory
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty
                || product.name.localizedCaseInsensitiveContains(query)
                || product.productDescription.localizedCaseInsensitiveContains(query)
                || product.category.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesSearch
        }
    }

    var featuredProduct: StoreProduct? {
        filteredProducts.max { first, second in
            if first.rating == second.rating {
                return first.reviewCount < second.reviewCount
            }
            return first.rating < second.rating
        }
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            products = try await api.getProducts()
        } catch {
            errorMessage = "Store products are temporarily unavailable."
        }
    }
}
