import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    private var isUser: Bool {
        message.role == "user"
    }

    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 48) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: DS.Spacing.xs) {
                if !isUser, let orderSummary = AssistantOrderSummary(message.content) {
                    AssistantOrderSummaryCard(summary: orderSummary)
                        .frame(maxWidth: 620, alignment: .leading)
                } else {
                    VStack(alignment: isUser ? .trailing : .leading, spacing: DS.Spacing.sm) {
                        if let imageData = message.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 220, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.row))
                                .accessibilityLabel("Uploaded image")
                        }

                        Text(message.content)
                            .font(.body)
                            .foregroundStyle(isUser ? .white : DS.ColorToken.primaryText)
                            .textSelection(.enabled)
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.vertical, DS.Spacing.md)
                    .background(bubbleBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.bubble, style: .continuous))
                    .frame(maxWidth: 620, alignment: isUser ? .trailing : .leading)
                }

                Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DS.Spacing.xs)
            }
            .accessibilityElement(children: .combine)

            if !isUser { Spacer(minLength: 48) }
        }
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            Color.accentColor
        } else {
            Rectangle().fill(.ultraThinMaterial)
        }
    }
}

private struct AssistantOrderSummary {
    var index: Int
    var orderID: Int
    var productName: String
    var price: Double
    var orderedAt: String
    var imageURL: URL?
    var followUpText: String

    init?(_ content: String) {
        let pattern = #"#(\d+)\.\s+(.+?)\s+\(Order\s+#(\d+)\)\s+[—-]\s+\$(\d+(?:\.\d+)?)\s+[—-]\s+Ordered\s+([^\n]+)\nImage:\s*(https?://\S+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        guard let match = regex.firstMatch(in: content, range: range),
              match.numberOfRanges == 7,
              let indexRange = Range(match.range(at: 1), in: content),
              let nameRange = Range(match.range(at: 2), in: content),
              let orderIDRange = Range(match.range(at: 3), in: content),
              let priceRange = Range(match.range(at: 4), in: content),
              let orderedAtRange = Range(match.range(at: 5), in: content),
              let imageURLRange = Range(match.range(at: 6), in: content),
              let index = Int(content[indexRange]),
              let orderID = Int(content[orderIDRange]),
              let price = Double(content[priceRange]) else {
            return nil
        }

        self.index = index
        self.orderID = orderID
        self.productName = String(content[nameRange])
        self.price = price
        self.orderedAt = String(content[orderedAtRange])
        self.imageURL = URL(string: String(content[imageURLRange]))

        let remainingRangeStart = Range(match.range, in: content)?.upperBound ?? content.endIndex
        self.followUpText = String(content[remainingRangeStart...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct AssistantOrderSummaryCard: View {
    let summary: AssistantOrderSummary

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            AsyncImage(url: summary.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    ZStack {
                        Color.accentColor.opacity(0.12)
                        Image(systemName: "bag.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.row))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                HStack {
                    Label("Order #\(summary.orderID)", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(DS.ColorToken.success)
                        .padding(.horizontal, DS.Spacing.sm)
                        .padding(.vertical, DS.Spacing.xs)
                        .background(DS.ColorToken.success.opacity(0.14), in: Capsule())

                    Spacer()
                }

                Text(summary.productName)
                    .font(.headline)
                    .foregroundStyle(DS.ColorToken.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Text(summary.price, format: .currency(code: "USD"))
                        .font(.title3.bold())
                        .foregroundStyle(.tint)
                    Spacer()
                    Text(summary.orderedAt)
                        .font(.caption)
                        .foregroundStyle(DS.ColorToken.secondaryText)
                }

                if !summary.followUpText.isEmpty {
                    Text(summary.followUpText)
                        .font(.body)
                        .foregroundStyle(DS.ColorToken.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, DS.Spacing.xs)
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DS.Radius.bubble, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DS.Radius.bubble, style: .continuous)
                .stroke(DS.ColorToken.separator.opacity(0.18), lineWidth: 1)
        }
    }
}
