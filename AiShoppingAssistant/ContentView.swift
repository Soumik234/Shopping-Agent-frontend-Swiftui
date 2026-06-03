import SwiftUI

@MainActor
struct ContentView: View {
    @State private var container: AppContainer
    @State private var chatViewModel: ChatViewModel
    @State private var storeViewModel: StoreViewModel
    @State private var ordersViewModel: OrdersViewModel
    @State private var preferencesViewModel: PreferencesViewModel
    @State private var profileViewModel: ProfileViewModel
    @State private var showSplash = true

    init() {
        self.init(container: AppContainer.shared)
    }

    init(container: AppContainer) {
        _container = State(initialValue: container)
        _chatViewModel = State(initialValue: ChatViewModel(api: container.api, container: container))
        _storeViewModel = State(initialValue: StoreViewModel(api: container.api))
        _ordersViewModel = State(initialValue: OrdersViewModel(api: container.api, container: container))
        _preferencesViewModel = State(initialValue: PreferencesViewModel(api: container.api, container: container))
        _profileViewModel = State(initialValue: ProfileViewModel(api: container.api))
    }

    var body: some View {
        ZStack {
            TabView(selection: $container.selectedTab) {
                ChatView(viewModel: chatViewModel)
                    .tabItem { Label("Assistant", systemImage: "sparkles") }
                    .tag(0)

                StoreView(viewModel: storeViewModel)
                    .tabItem { Label("Store", systemImage: "storefront.fill") }
                    .tag(1)

                OrdersView(viewModel: ordersViewModel)
                    .tabItem { Label("Orders", systemImage: "bag.fill") }
                    .tag(2)

                ProfileView(
                    viewModel: profileViewModel,
                    preferencesViewModel: preferencesViewModel,
                    container: container
                ) {
                    chatViewModel.clearConversation()
                }
                .tabItem { Label("Profile", systemImage: "person.circle.fill") }
                .tag(3)
            }
            .environment(container)
            .preferredColorScheme(container.theme.colorScheme)

            if showSplash {
                SplashView {
                    showSplash = false
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSplash)
    }
}

#Preview {
    ContentView()
}
