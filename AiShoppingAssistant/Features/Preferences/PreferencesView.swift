import SwiftUI

struct PreferencesView: View {
    @Bindable var viewModel: PreferencesViewModel
    var showsNavigationStack = true

    var body: some View {
        if showsNavigationStack {
            NavigationStack {
                preferencesForm
            }
        } else {
            preferencesForm
        }
    }

    private var preferencesForm: some View {
        Form {
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(DS.ColorToken.error)
                    }
                }

                Section("Shopping Defaults") {
                    Toggle("Default to organic products", isOn: $viewModel.organic)
                        .onChange(of: viewModel.organic) { _, _ in
                            lightHaptic()
                            Task { await viewModel.saveBuiltIn(key: "organic") }
                        }

                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        HStack {
                            Text("Max budget")
                            Spacer()
                            Text(viewModel.maxPrice, format: .currency(code: "USD").precision(.fractionLength(0)))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $viewModel.maxPrice, in: 1...100, step: 1) {
                            Text("Max budget")
                        }
                        .onChange(of: viewModel.maxPrice) { _, _ in
                            Task { await viewModel.saveBuiltIn(key: "max_price") }
                        }
                    }

                    Picker("Category", selection: $viewModel.category) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category.capitalized).tag(category)
                        }
                    }
                    .onChange(of: viewModel.category) { _, _ in
                        lightHaptic()
                        Task { await viewModel.saveBuiltIn(key: "category") }
                    }

                    Picker("Minimum rating", selection: $viewModel.minRating) {
                        ForEach(viewModel.ratingOptions, id: \.self) { rating in
                            Text(rating == "Any" ? "Any" : "\(rating)★").tag(rating)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.minRating) { _, _ in
                        lightHaptic()
                        Task { await viewModel.saveBuiltIn(key: "min_rating") }
                    }
                }

                Section {
                    ForEach($viewModel.customPreferences) { $item in
                        VStack(spacing: DS.Spacing.sm) {
                            TextField("Key", text: $item.key)
                                .textInputAutocapitalization(.never)
                            TextField("Value", text: $item.value)
                                .textInputAutocapitalization(.never)
                            Button("Save", systemImage: "checkmark.circle") {
                                lightHaptic()
                                Task { await viewModel.saveCustomPreference(item) }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.vertical, DS.Spacing.xs)
                    }
                    .onDelete(perform: viewModel.deleteCustomPreference)
                } header: {
                    HStack {
                        Text("Custom Preferences")
                        Spacer()
                        Button("Add preference", systemImage: "plus") {
                            viewModel.addCustomPreference()
                        }
                        .labelStyle(.iconOnly)
                    }
                }
            }
            .navigationTitle("Preferences")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add preference", systemImage: "plus") {
                        viewModel.addCustomPreference()
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }
