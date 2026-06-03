import Foundation

struct StoreProduct: Codable, Identifiable, Equatable {
    var id: Int
    var name: String
    var category: String
    var price: Double
    var productDescription: String
    var isOrganic: Bool
    var imageURL: URL?
    var rating: Double
    var reviews: [StoreProductReview]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case price
        case productDescription = "description"
        case isOrganic = "is_organic"
        case imageURL = "image_url"
        case rating
        case reviews
    }

    var displayCategory: String {
        category.capitalized
    }

    var reviewCount: Int {
        reviews.count
    }

    nonisolated var displayImageURL: URL? {
        imageURL ?? Self.searchImageURL(for: name)
    }

    nonisolated var localImageAssetCandidates: [String] {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseNames = Self.assetNameBases(for: trimmedName)
        return Self.unique(baseNames.flatMap(Self.assetNameFormats))
    }

    nonisolated private static func searchImageURL(for name: String) -> URL? {
        var components = URLComponents(string: "https://source.unsplash.com/500x400/")
        components?.queryItems = [
            URLQueryItem(name: "food", value: name)
        ]
        return components?.url
    }

    nonisolated private static func assetNameBases(for name: String) -> [String] {
        let descriptorPrefixes = [
            "Organic ",
            "Roasted ",
            "Dark Roast "
        ]
        var bases = [name]

        for prefix in descriptorPrefixes where hasCaseInsensitivePrefix(prefix, in: name) {
            bases.append(String(name.dropFirst(prefix.count)))
        }

        for base in bases {
            bases.append(singularizedWords(base))

            let words = base.split(separator: " ").map(String.init)
            if let lastWord = words.last {
                bases.append(singularizedWords(lastWord))
            }
            if words.count >= 2 {
                bases.append(singularizedWords(words.suffix(2).joined(separator: " ")))
            }
        }

        return unique(bases)
    }

    nonisolated private static func assetNameFormats(for name: String) -> [String] {
        let lowercasedName = name.lowercased()
        let hyphenatedName = name.replacingOccurrences(of: " ", with: "-")
        let lowercasedHyphenatedName = lowercasedName.replacingOccurrences(of: " ", with: "-")
        let sentenceCasedName = lowercasedName.prefix(1).uppercased() + lowercasedName.dropFirst()
        let sentenceCasedHyphenatedName = sentenceCasedName.replacingOccurrences(of: " ", with: "-")

        return [
            name,
            lowercasedName,
            hyphenatedName,
            lowercasedHyphenatedName,
            sentenceCasedName,
            sentenceCasedHyphenatedName
        ]
    }

    nonisolated private static func singularizedWords(_ name: String) -> String {
        name
            .split(separator: " ")
            .map { word in
                let text = String(word)
                if text.lowercased().hasSuffix("ies") {
                    return String(text.dropLast(3)) + "y"
                }
                if text.lowercased().hasSuffix("s"), text.count > 1 {
                    return String(text.dropLast())
                }
                return text
            }
            .joined(separator: " ")
    }

    nonisolated private static func hasCaseInsensitivePrefix(_ prefix: String, in name: String) -> Bool {
        name.range(of: prefix, options: [.anchored, .caseInsensitive]) != nil
    }

    nonisolated private static func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { value in
            guard !value.isEmpty, !seen.contains(value) else { return false }
            seen.insert(value)
            return true
        }
    }
}

struct StoreProductReview: Codable, Identifiable, Equatable {
    var rating: Double
    var reviewerName: String
    var reviewText: String

    enum CodingKeys: String, CodingKey {
        case rating
        case reviewerName = "reviewer_name"
        case reviewText = "review_text"
    }

    var id: String {
        "\(reviewerName)-\(rating)-\(reviewText)"
    }
}
