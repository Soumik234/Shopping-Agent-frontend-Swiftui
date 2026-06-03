import SwiftUI

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    @Environment(AppContainer.self) private var container
    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ChatHeader(
                    onClear: { showClearAlert = true },
                    onOrders: { container.selectedTab = 2 }
                )
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.top, DS.Spacing.sm)
                .padding(.bottom, DS.Spacing.md)

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: DS.Spacing.lg) {
                            if let errorMessage = viewModel.errorMessage {
                                ErrorBannerView(message: errorMessage) {
                                    Task { await viewModel.retryLastRequest() }
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }

                            if viewModel.messages.isEmpty && !viewModel.isLoading {
                                ChatEmptyState { suggestion in
                                    Task { await viewModel.useSuggestion(suggestion) }
                                }
                                .padding(.top, DS.Spacing.lg)
                            }

                            ForEach(viewModel.messages) { message in
                                messageContent(message)
                                    .id(message.id)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }

                            if viewModel.isLoading {
                                TypingIndicatorView(label: viewModel.thinkingLabel)
                                    .id("typing")
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.top, DS.Spacing.sm)
                        .padding(.bottom, DS.Spacing.xxl)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        scrollToBottom(proxy)
                    }
                    .onChange(of: viewModel.isLoading) { _, _ in
                        scrollToBottom(proxy)
                    }
                }
            }
            .background(DS.ColorToken.background)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                ChatInputBar(viewModel: viewModel) {
                    tapHaptic()
                    Task { await viewModel.sendMessage() }
                }
            }
            .alert("Clear conversation?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    warningHaptic()
                    viewModel.clearConversation()
                }
            } message: {
                Text("This removes the local chat history from this session.")
            }
            .sheet(item: $viewModel.productPendingConfirmation) { product in
                OrderConfirmationSheet(product: product) {
                    tapHaptic()
                    Task { await viewModel.order(product) }
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $viewModel.showOrderSuccess) {
                OrderSuccessView(message: viewModel.lastOrderMessage)
                    .presentationDetents([.medium])
            }
        }
    }

    @ViewBuilder
    private func messageContent(_ message: ChatMessage) -> some View {
        let products = viewModel.products(for: message)
        if message.role == "assistant", !products.isEmpty {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.md) {
                        ForEach(products) { product in
                            ProductCardView(product: product) {
                                tapHaptic()
                                viewModel.productPendingConfirmation = product
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.vertical, DS.Spacing.lg)
                }
                .scrollClipDisabled()
                .padding(.horizontal, -DS.Spacing.lg)
            }
        } else {
            MessageBubble(message: message)
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.snappy) {
                if viewModel.isLoading {
                    proxy.scrollTo("typing", anchor: .bottom)
                } else if let last = viewModel.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}

struct ChatHeader: View {
    var onClear: () -> Void
    var onOrders: () -> Void

    var body: some View {
        HStack {
            Button("Clear conversation", systemImage: "trash", action: onClear)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(.thinMaterial, in: Circle())

            Spacer()

            Text("AI Shopping")
                .font(.headline.weight(.semibold))
                .foregroundStyle(DS.ColorToken.primaryText)

            Spacer()

            Button("Orders", systemImage: "clock", action: onOrders)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(.thinMaterial, in: Circle())
        }
        .accessibilityElement(children: .contain)
    }
}

struct ErrorBannerView: View {
    var message: String
    var onRetry: (() -> Void)?

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(DS.ColorToken.error)
            Text(message)
                .font(.footnote)
            Spacer()
            if let onRetry {
                Button("Retry", action: onRetry)
                    .font(.footnote.bold())
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, 10)
        .background(DS.ColorToken.error.opacity(0.1), in: RoundedRectangle(cornerRadius: DS.Radius.row))
    }
}

struct ChatEmptyState: View {
    var onSuggestion: (String) -> Void
    private let suggestions = [
        Suggestion(icon: "leaf.fill", title: "Organic honey", subtitle: "Compare natural options"),
        Suggestion(icon: "star.fill", title: "Best rated oils", subtitle: "Find top reviewed picks"),
        Suggestion(icon: "tag.fill", title: "Under $10", subtitle: "Keep it budget friendly")
    ]

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            VStack(spacing: DS.Spacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.accentColor, in: Circle())
                    .shadow(color: Color.accentColor.opacity(0.25), radius: 16, y: 8)

                VStack(spacing: DS.Spacing.sm) {
                    Text("What are you shopping for?")
                        .font(.title2.bold())
                        .foregroundStyle(DS.ColorToken.primaryText)
                        .multilineTextAlignment(.center)

                    Text("Ask for a product, budget, brand, or upload a photo to compare options.")
                        .font(.subheadline)
                        .foregroundStyle(DS.ColorToken.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .frame(maxWidth: 330)
            }

            VStack(spacing: DS.Spacing.sm) {
                ForEach(suggestions) { suggestion in
                    suggestionButton(suggestion)
                }
            }
            .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, DS.Spacing.xl)
    }

    private func suggestionButton(_ suggestion: Suggestion) -> some View {
        Button {
            onSuggestion(suggestion.title)
        } label: {
            HStack(spacing: DS.Spacing.md) {
                Image(systemName: suggestion.icon)
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 36, height: 36)
                    .background(Color.accentColor.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .font(.headline)
                        .foregroundStyle(DS.ColorToken.primaryText)

                    Text(suggestion.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(DS.ColorToken.secondaryText)
                }
                .lineLimit(1)

                Spacer(minLength: DS.Spacing.sm)

                Image(systemName: "chevron.right")
                    .font(.footnote.bold())
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(DS.ColorToken.surface, in: RoundedRectangle(cornerRadius: DS.Radius.row))
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.row)
                    .stroke(DS.ColorToken.separator.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private struct Suggestion: Identifiable {
        let icon: String
        let title: String
        let subtitle: String

        var id: String { title }
    }
}

struct OrderConfirmationSheet: View {
    let product: ParsedProduct
    var onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            Image(systemName: "bag.badge.plus")
                .font(.system(size: 52))
                .foregroundStyle(.tint)

            VStack(spacing: DS.Spacing.sm) {
                Text(product.name)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                Text(product.price, format: .currency(code: "USD"))
                    .font(.title.bold())
                    .foregroundStyle(.tint)
                StarRatingView(rating: product.rating)
            }

            Button {
                dismiss()
                onConfirm()
            } label: {
                Label("Confirm Order", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(DS.Spacing.xl)
    }
}

struct OrderSuccessView: View {
    let message: String
    @Environment(\.dismiss) private var dismiss
    @State private var scale = 0.1

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(DS.ColorToken.success)
                .scaleEffect(scale)

            Text("Order Placed!")
                .font(.title.bold())
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DS.Spacing.xl)
        .onAppear {
            successHaptic()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                scale = 1
            }
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                dismiss()
            }
        }
        .onTapGesture { dismiss() }
    }
}
