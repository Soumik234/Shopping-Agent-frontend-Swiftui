import SwiftUI

@main
@MainActor
struct AiShoppingAssistantApp: App {
    @State private var container = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
                .environment(container)
        }
    }
}
