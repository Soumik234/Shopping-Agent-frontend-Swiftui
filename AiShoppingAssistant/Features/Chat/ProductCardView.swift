import SwiftUI

struct ProductCardView: View {
    let product: ParsedProduct
    var onBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(product.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(DS.ColorToken.primaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

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

                Spacer()

                Text("#\(product.index)")
                    .font(.caption)
                    .foregroundStyle(DS.ColorToken.secondaryText)
                    .padding(.horizontal, DS.Spacing.sm)
                    .padding(.vertical, DS.Spacing.xs)
                    .background(.thinMaterial, in: Capsule())
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text(product.price, format: .currency(code: "USD"))
                    .font(.title3.bold())
                    .foregroundStyle(.tint)

                if product.isOrganic {
                    Label("Organic", systemImage: "leaf.fill")
                        .font(.caption.bold())
                        .foregroundStyle(DS.ColorToken.success)
                        .padding(.horizontal, DS.Spacing.sm)
                        .padding(.vertical, DS.Spacing.xs)
                        .background(DS.ColorToken.success.opacity(0.14), in: Capsule())
                }
            }

            Button {
                onBuy()
            } label: {
                Label("Buy", systemImage: "bag.fill")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
            .accessibilityLabel("Buy \(product.name) for \(product.price.formatted(.currency(code: "USD")))")
        }
        .padding(DS.Spacing.md)
        .frame(width: 232, height: 196, alignment: .topLeading)
        .background(DS.ColorToken.surface, in: RoundedRectangle(cornerRadius: DS.Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .stroke(DS.ColorToken.separator.opacity(0.25), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 8)
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
