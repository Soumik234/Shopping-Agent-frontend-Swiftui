import SwiftUI

struct StoreView: View {
    @Bindable var viewModel: StoreViewModel
    @State private var selectedProduct: StoreProduct?

    private let columns = [
        GridItem(.flexible(minimum: 0), spacing: DS.Spacing.md),
        GridItem(.flexible(minimum: 0), spacing: DS.Spacing.md)
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DS.Spacing.lg) {
                    if let errorMessage = viewModel.errorMessage {
                        StoreErrorBanner(message: errorMessage) {
                            Task { await viewModel.load() }
                        }
                    }

                    if let featuredProduct = viewModel.featuredProduct, viewModel.searchText.isEmpty {
                        StoreFeaturedProductView(product: featuredProduct) {
                            selectedProduct = featuredProduct
                        }
                    }

                    categoryPicker

                    LazyVGrid(columns: columns, spacing: DS.Spacing.md) {
                        ForEach(viewModel.filteredProducts) { product in
                            StoreProductTile(product: product) {
                                selectedProduct = product
                            }
                        }
                    }

                    StoreBottomTabBarReserve()
                }
                .padding(DS.Spacing.lg)
            }
            .background(DS.ColorToken.background)
            .navigationTitle("Store")
            .searchable(text: $viewModel.searchText, prompt: "Search products")
            .refreshable {
                rigidHaptic()
                await viewModel.load()
            }
            .overlay {
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView()
                } else if viewModel.filteredProducts.isEmpty && !viewModel.isLoading {
                    StoreEmptyState()
                }
            }
            .task {
                await viewModel.load()
            }
            .sheet(item: $selectedProduct) { product in
                StoreProductDetailView(product: product)
                    .presentationDetents([.large])
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Button {
                        lightHaptic()
                        viewModel.selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(viewModel.selectedCategory == category ? .white : DS.ColorToken.primaryText)
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(
                                viewModel.selectedCategory == category ? Color.accentColor : DS.ColorToken.surface,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, DS.Spacing.xs)
        }
        .scrollClipDisabled()
    }
}

private struct StoreBottomTabBarReserve: View {
    var body: some View {
        Color.clear
            .frame(height: 156)
            .frame(maxWidth: .infinity)
    }
}

struct StoreFeaturedProductView: View {
    let product: StoreProduct
    var onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                StoreProductImage(product: product, placeholderIcon: "shippingbox.fill")
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))

                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    HStack {
                        StoreBadge(text: "Featured", systemImage: "sparkles", color: Color.accentColor)
                        if product.isOrganic {
                            StoreBadge(text: "Organic", systemImage: "leaf.fill", color: DS.ColorToken.success)
                        }
                    }

                    Text(product.name)
                        .font(.title2.bold())
                        .foregroundStyle(DS.ColorToken.primaryText)

                    Text(product.productDescription)
                        .font(.subheadline)
                        .foregroundStyle(DS.ColorToken.secondaryText)
                        .lineLimit(2)

                    HStack {
                        StoreRatingView(rating: product.rating, reviewCount: product.reviewCount)
                        Spacer()
                        Text(product.price, format: .currency(code: "USD"))
                            .font(.title3.bold())
                            .foregroundStyle(.tint)
                    }
                }
            }
            .padding(DS.Spacing.md)
            .background(DS.ColorToken.surface, in: RoundedRectangle(cornerRadius: DS.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.card)
                    .stroke(DS.ColorToken.separator.opacity(0.25), lineWidth: 1)
            }
            .productCardShadow()
        }
        .buttonStyle(.plain)
    }
}

struct StoreProductTile: View {
    let product: StoreProduct
    var onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    GeometryReader { proxy in
                        StoreProductImage(product: product, placeholderIcon: "photo")
                            .frame(width: proxy.size.width, height: 104)
                            .clipped()
                    }
                    .frame(height: 104)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.row))

                    Text(product.displayCategory)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                        .lineLimit(1)

                    Text(product.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(DS.ColorToken.primaryText)
                        .lineLimit(2, reservesSpace: true)

                    Text(product.productDescription)
                        .font(.caption)
                        .foregroundStyle(DS.ColorToken.secondaryText)
                        .lineLimit(2, reservesSpace: true)
                }

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    StoreRatingView(rating: product.rating, reviewCount: product.reviewCount)
                        .lineLimit(1)

                    Text(product.price, format: .currency(code: "USD"))
                        .font(.title3.bold())
                        .foregroundStyle(.tint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    if product.isOrganic {
                        StoreBadge(text: "Organic", systemImage: "leaf.fill", color: DS.ColorToken.success)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    } else {
                        StoreBadge(text: "Organic", systemImage: "leaf.fill", color: DS.ColorToken.success)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .opacity(0)
                            .accessibilityHidden(true)
                    }
                }
            }
            .padding(DS.Spacing.sm)
            .frame(maxWidth: .infinity, minHeight: 324, maxHeight: 324, alignment: .topLeading)
            .background(DS.ColorToken.surface, in: RoundedRectangle(cornerRadius: DS.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.card)
                    .stroke(DS.ColorToken.separator.opacity(0.25), lineWidth: 1)
            }
            .productCardShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(product.name), \(product.price.formatted(.currency(code: "USD"))), rated \(product.rating.formatted(.number.precision(.fractionLength(1)))) from \(product.reviewCount) reviews")
    }
}

struct StoreProductDetailView: View {
    let product: StoreProduct

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = DS.Spacing.xl
            let contentWidth = max(proxy.size.width - (horizontalPadding * 2), 0)

            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.xl) {
                    StoreProductImage(product: product, placeholderIcon: "shippingbox.fill")
                        .frame(width: contentWidth, height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))

                    VStack(alignment: .leading, spacing: DS.Spacing.md) {
                        HStack {
                            StoreBadge(text: product.displayCategory, systemImage: "tag.fill", color: Color.accentColor)
                            if product.isOrganic {
                                StoreBadge(text: "Organic", systemImage: "leaf.fill", color: DS.ColorToken.success)
                            }
                        }

                        Text(product.name)
                            .font(.title.bold())
                            .foregroundStyle(DS.ColorToken.primaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        StoreRatingView(rating: product.rating, reviewCount: product.reviewCount)

                        Text(product.price, format: .currency(code: "USD"))
                            .font(.largeTitle.bold())
                            .foregroundStyle(.tint)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("Description")
                            .font(.headline)
                        Text(product.productDescription)
                            .font(.body)
                            .foregroundStyle(DS.ColorToken.secondaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.md) {
                        StoreDetailRow(icon: "number", title: "Product ID", value: product.id.formatted())
                        StoreDetailRow(icon: "shippingbox.fill", title: "Category", value: product.displayCategory)
                        StoreDetailRow(icon: "star.fill", title: "Reviews", value: product.reviewCount.formatted())
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.md) {
                        Text("Customer Reviews")
                            .font(.headline)

                        ForEach(product.reviews) { review in
                            StoreReviewRow(review: review)
                        }
                    }
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, DS.Spacing.xl)
            }
            .background(DS.ColorToken.background)
        }
    }
}

struct StoreRatingView: View {
    let rating: Double
    let reviewCount: Int

    var body: some View {
        Label {
            Text("\(rating.formatted(.number.precision(.fractionLength(1)))) (\(reviewCount.formatted()))")
                .font(.caption)
                .foregroundStyle(DS.ColorToken.secondaryText)
        } icon: {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundStyle(DS.ColorToken.rating)
        }
        .accessibilityLabel("Rated \(rating.formatted(.number.precision(.fractionLength(1)))) from \(reviewCount.formatted()) reviews")
    }
}

struct StoreReviewRow: View {
    let review: StoreProductReview

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text(review.reviewerName)
                    .font(.subheadline.bold())
                    .foregroundStyle(DS.ColorToken.primaryText)
                Spacer()
                StoreRatingView(rating: review.rating, reviewCount: 1)
            }

            Text(review.reviewText)
                .font(.subheadline)
                .foregroundStyle(DS.ColorToken.secondaryText)
                .lineSpacing(2)
        }
        .padding(DS.Spacing.md)
        .background(DS.ColorToken.surface, in: RoundedRectangle(cornerRadius: DS.Radius.row))
        .overlay {
            RoundedRectangle(cornerRadius: DS.Radius.row)
                .stroke(DS.ColorToken.separator.opacity(0.2), lineWidth: 1)
        }
    }
}

struct StoreBadge: View {
    let text: String
    let systemImage: String
    let color: Color

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.bold())
            .foregroundStyle(color)
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, DS.Spacing.xs)
            .background(color.opacity(0.14), in: Capsule())
    }
}

struct StoreDetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 30, height: 30)
                .background(Color.accentColor.opacity(0.12), in: Circle())
            Text(title)
                .foregroundStyle(DS.ColorToken.secondaryText)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(DS.ColorToken.primaryText)
        }
    }
}

struct StoreErrorBanner: View {
    var message: String
    var onRetry: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(DS.ColorToken.error)
            Text(message)
                .font(.footnote)
            Spacer()
            Button("Retry", action: onRetry)
                .font(.footnote.bold())
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, 10)
        .background(DS.ColorToken.error.opacity(0.1), in: RoundedRectangle(cornerRadius: DS.Radius.row))
    }
}

struct StoreEmptyState: View {
    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "shippingbox")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No products found")
                .font(.title3.bold())
            Text("Try a different search or category.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(DS.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StoreImagePlaceholder: View {
    let icon: String

    var body: some View {
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

struct StoreProductImage: View {
    let product: StoreProduct
    let placeholderIcon: String

    var body: some View {
        if let assetName = localAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            AsyncImage(url: product.displayImageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    StoreImagePlaceholder(icon: placeholderIcon)
                }
            }
        }
    }

    private var localAssetName: String? {
        product.localImageAssetCandidates.first { UIImage(named: $0) != nil }
    }
}
