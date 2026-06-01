import Foundation

struct ParsedProduct: Identifiable, Equatable {
    var id: Int
    var index: Int
    var name: String
    var price: Double
    var rating: Double
    var isOrganic: Bool
}
