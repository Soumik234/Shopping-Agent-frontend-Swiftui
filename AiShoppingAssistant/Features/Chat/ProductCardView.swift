import SwiftUI

struct ProductCardView: View {
    let product: ParsedProduct
    var onBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            productImage

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(product.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(DS.ColorToken.primaryText)
                    .lineLimit(2, reservesSpace: true)

                ratingLabel
            }
            .frame(height: 58, alignment: .topLeading)

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(product.price, format: .currency(code: "USD"))
                    .font(.title3.bold())
                    .foregroundStyle(.tint)

                organicBadge
            }
            .frame(height: 56, alignment: .topLeading)

            Button {
                onBuy()
            } label: {
                Label("Buy", systemImage: "bag.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: DS.Radius.button))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Buy \(product.name) for \(product.price.formatted(.currency(code: "USD")))")
        }
        .padding(DS.Spacing.md)
        .frame(width: 236, height: 320, alignment: .topLeading)
        .background(DS.ColorToken.surface, in: RoundedRectangle(cornerRadius: DS.Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .stroke(DS.ColorToken.separator.opacity(0.25), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 8)
    }

    @ViewBuilder
    private var ratingLabel: some View {
        if product.rating > 0 {
            Label {
                Text(product.rating, format: .number.precision(.fractionLength(1)))
                    .font(.caption)
                    .foregroundStyle(DS.ColorToken.secondaryText)
            } icon: {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(DS.ColorToken.rating)
            }
        } else {
            Label {
                Text("Recommended")
                    .font(.caption)
                    .foregroundStyle(DS.ColorToken.secondaryText)
            } icon: {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.tint)
            }
        }
    }

    @ViewBuilder
    private var organicBadge: some View {
        if product.isOrganic {
            Label("Organic", systemImage: "leaf.fill")
                .font(.caption.bold())
                .foregroundStyle(DS.ColorToken.success)
                .padding(.horizontal, DS.Spacing.sm)
                .padding(.vertical, DS.Spacing.xs)
                .background(DS.ColorToken.success.opacity(0.14), in: Capsule())
        } else {
            Text("Conventional")
                .font(.caption.bold())
                .foregroundStyle(DS.ColorToken.secondaryText)
                .padding(.horizontal, DS.Spacing.sm)
                .padding(.vertical, DS.Spacing.xs)
                .background(DS.ColorToken.separator.opacity(0.12), in: Capsule())
                .opacity(0)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var productImage: some View {
        AsyncImage(url: product.displayImageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                imagePlaceholder(icon: "photo")
            default:
                imagePlaceholder(icon: "shippingbox.fill")
            }
        }
        .frame(width: 212, height: 104)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.row))
        .overlay(alignment: .topTrailing) {
            Text("#\(product.index)")
                .font(.caption.bold())
                .foregroundStyle(DS.ColorToken.secondaryText)
                .padding(.horizontal, DS.Spacing.sm)
                .padding(.vertical, DS.Spacing.xs)
                .background(.regularMaterial, in: Capsule())
                .padding(DS.Spacing.sm)
        }
    }

    private func imagePlaceholder(icon: String) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.16), DS.ColorToken.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
        }
    }
}

struct StarRatingView: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: Double(index) <= rating.rounded(.down) ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(DS.ColorToken.rating)
            }

            Text(rating, format: .number.precision(.fractionLength(1)))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rated \(rating.formatted(.number.precision(.fractionLength(1)))) out of 5 stars")
    }
}
