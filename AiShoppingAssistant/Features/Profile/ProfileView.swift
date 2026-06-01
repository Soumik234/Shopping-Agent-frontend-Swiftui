import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    @Bindable var preferencesViewModel: PreferencesViewModel
    @Bindable var container: AppContainer
    var clearChat: () -> Void

    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("API Status") {
                    HStack {
                        Circle()
                            .fill(viewModel.isConnected ? DS.ColorToken.success : DS.ColorToken.error)
                            .frame(width: 12, height: 12)
                            .accessibilityLabel("API status: \(viewModel.isConnected ? "Connected" : "Offline")")
                        Text(viewModel.isConnected ? "Connected" : "Offline")
                        Spacer()
                        if viewModel.isChecking {
                            ProgressView()
                        }
                    }

                    Button("Check Again", systemImage: "arrow.clockwise") {
                        Task { await viewModel.checkHealth() }
                    }
                }

                Section("Shopping") {
                    NavigationLink {
                        PreferencesView(viewModel: preferencesViewModel, showsNavigationStack: false)
                    } label: {
                        Label("Preferences", systemImage: "slider.horizontal.3")
                    }
                }

                Section("Stats") {
                    LabeledContent("Total orders", value: container.orderCount.formatted())
                    LabeledContent("Preferences", value: container.preferenceCount.formatted())
                }

                Section("Theme") {
                    Picker("Appearance", selection: $container.theme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0")
                    Text("SwiftUI, MVVM, Async/Await, FastAPI, LangChain, SQLite")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Link("GitHub", destination: URL(string: "https://github.com")!)
                }

                Section {
                    Button("Clear Local Chat", systemImage: "trash", role: .destructive) {
                        showClearAlert = true
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                await viewModel.checkHealth()
            }
            .alert("Clear local chat?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    warningHaptic()
                    clearChat()
                }
            } message: {
                Text("This clears the current conversation from this device session.")
            }
        }
    }
}
