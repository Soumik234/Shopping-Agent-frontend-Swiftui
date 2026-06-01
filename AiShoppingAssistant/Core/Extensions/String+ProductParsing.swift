import Foundation

extension String {
    func parsedProducts() -> [ParsedProduct] {
        let pattern = #"#?(\d+)\.\s+(.+?)\s+\(ID:\s*(\d+)\)\s+[—-]\s+\$(\d+(?:\.\d+)?)(?:\s*★\s*(\d+(?:\.\d+)?))?(?:\s+[—-]\s+([A-Za-z-]+))?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        let range = NSRange(startIndex..<endIndex, in: self)
        return regex.matches(in: self, range: range).compactMap { match in
            guard match.numberOfRanges == 7,
                  let indexRange = Range(match.range(at: 1), in: self),
                  let nameRange = Range(match.range(at: 2), in: self),
                  let idRange = Range(match.range(at: 3), in: self),
                  let priceRange = Range(match.range(at: 4), in: self),
                  let index = Int(self[indexRange]),
                  let id = Int(self[idRange]),
                  let price = Double(self[priceRange]) else {
                return nil
            }

            let rating: Double
            if let ratingRange = Range(match.range(at: 5), in: self),
               let parsedRating = Double(self[ratingRange]) {
                rating = parsedRating
            } else {
                rating = 0
            }

            let organicValue: String
            if let organicRange = Range(match.range(at: 6), in: self) {
                organicValue = self[organicRange].lowercased()
            } else {
                organicValue = ""
            }

            return ParsedProduct(
                id: id,
                index: index,
                name: String(self[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines),
                price: price,
                rating: rating,
                isOrganic: organicValue == "organic"
            )
        }
    }

    func parsedConfirmedOrder() -> Order? {
        let pattern = #"Order\s+#(\d+)\s+confirmed!\s+'(.+?)'\s+has been successfully ordered for\s+\$(\d+(?:\.\d+)?)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let range = NSRange(startIndex..<endIndex, in: self)
        guard let match = regex.firstMatch(in: self, range: range),
              match.numberOfRanges == 4,
              let orderIdRange = Range(match.range(at: 1), in: self),
              let nameRange = Range(match.range(at: 2), in: self),
              let priceRange = Range(match.range(at: 3), in: self),
              let orderId = Int(self[orderIdRange]),
              let price = Double(self[priceRange]) else {
            return nil
        }

        return Order(
            orderId: orderId,
            productId: orderId,
            productName: String(self[nameRange]),
            price: price,
            orderedAt: ISO8601DateFormatter().string(from: Date())
        )
    }
}
