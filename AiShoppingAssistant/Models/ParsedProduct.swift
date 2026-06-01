import Foundation

struct ParsedProduct: Codable, Identifiable, Equatable {
    var id: Int
    var index: Int
    var name: String
    var price: Double
    var rating: Double
    var isOrganic: Bool
    var imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case index
        case name
        case price
        case rating
        case isOrganic = "is_organic"
        case imageURL = "image_url"
    }

    var displayImageURL: URL? {
        imageURL ?? Self.searchImageURL(for: name)
    }

    private static func searchImageURL(for name: String) -> URL? {
        var components = URLComponents(string: "https://source.unsplash.com/400x300/")
        components?.queryItems = [
            URLQueryItem(name: "food", value: name)
        ]
        return components?.url
    }
}
