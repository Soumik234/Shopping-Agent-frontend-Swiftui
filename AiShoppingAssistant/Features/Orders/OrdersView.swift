import SwiftUI

struct OrdersView: View {
    @Bindable var viewModel: OrdersViewModel
    @Environment(AppContainer.self) private var container
    @State private var selectedOrder: Order?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.orders.isEmpty && !viewModel.isLoading {
                    OrdersEmptyState {
                        container.selectedTab = 0
                    }
                } else {
                    List(viewModel.orders) { order in
                        Button {
                            selectedOrder = order
                        } label: {
                            OrderRowView(order: order)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Order \(order.orderId), \(order.productName), \(order.price.formatted(.currency(code: "USD"))), placed on \(order.formattedDate)")
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        rigidHaptic()
                        await viewModel.load()
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Orders")
            .task(id: "\(container.selectedTab)-\(container.orderRefreshID)") {
                guard container.selectedTab == 2 else { return }
                await viewModel.load()
            }
            .sheet(item: $selectedOrder) { order in
                OrderDetailSheet(order: order)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct OrderRowView: View {
    let order: Order

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            orderThumbnail

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(order.productName)
                    .font(.headline)
                    .foregroundStyle(DS.ColorToken.primaryText)
                Text("Order #\(order.orderId)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(order.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(order.price, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(.tint)
        }
        .padding(.vertical, DS.Spacing.xs)
    }

    private var orderThumbnail: some View {
        AsyncImage(url: order.imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                ZStack {
                    Color.accentColor.opacity(0.16)
                    Image(systemName: "bag.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.row))
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(DS.ColorToken.success)
                .frame(width: 12, height: 12)
                .overlay {
                    Circle()
                        .stroke(DS.ColorToken.surface, lineWidth: 2)
                }
                .offset(x: 2, y: 2)
        }
        .accessibilityHidden(true)
    }
}

struct OrdersEmptyState: View {
    var openAssistant: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "bag")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("No orders yet")
                .font(.title3.bold())
            Text("Ask the assistant to find something.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Find Something", systemImage: "sparkles", action: openAssistant)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DS.Spacing.xl)
        .background(DS.ColorToken.background)
    }
}

struct OrderDetailSheet: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xl) {
            AsyncImage(url: order.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    ZStack {
                        Color.accentColor.opacity(0.14)
                        Image(systemName: "bag.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text(order.productName)
                    .font(.title3.bold())
                Text("Order #\(order.orderId)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                TimelineStep(icon: "checkmark.circle.fill", title: "Order Placed", isActive: true)
                TimelineStep(icon: "gearshape.fill", title: "Processing", isActive: true)
                TimelineStep(icon: "shippingbox.fill", title: "Arriving in 3-5 days", isActive: false)
            }

            Spacer()

            Text(order.price, format: .currency(code: "USD"))
                .font(.largeTitle.bold())
                .foregroundStyle(.tint)
        }
        .padding(DS.Spacing.xl)
    }
}

struct TimelineStep: View {
    let icon: String
    let title: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(isActive ? DS.ColorToken.success : .secondary)
                .frame(width: 32, height: 32)
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}
