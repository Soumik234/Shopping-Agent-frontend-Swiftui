import PhotosUI
import SwiftUI

struct ChatInputBar: View {
    @Bindable var viewModel: ChatViewModel
    var onSend: () -> Void

    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            if let image = viewModel.selectedImage {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.badge))
                        .accessibilityLabel("Selected image preview")

                    Text("Image ready")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button("Clear image", systemImage: "xmark.circle.fill") {
                        viewModel.selectedImage = nil
                        viewModel.selectedImageData = nil
                    }
                    .labelStyle(.iconOnly)
                    .font(.title3)
                }
                .transition(.scale.combined(with: .opacity))
            }

            let hasSelectedImage = viewModel.selectedImage != nil

            HStack(alignment: .bottom, spacing: DS.Spacing.sm) {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Image(systemName: hasSelectedImage ? "xmark.circle" : "camera.fill")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                        .foregroundStyle(Color.accentColor)
                        .background(Color.accentColor.opacity(0.12), in: Circle())
                }
                .accessibilityLabel("Attach image")

                TextField("Ask about any product...", text: $viewModel.inputText, axis: .vertical)
                    .font(.body)
                    .lineLimit(1...4)
                    .textFieldStyle(.plain)
                    .padding(.vertical, DS.Spacing.md)

                Button {
                    onSend()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.headline.bold())
                        .frame(width: 44, height: 44)
                        .background(sendDisabled ? Color.secondary.opacity(0.16) : Color.accentColor, in: Circle())
                }
                .disabled(sendDisabled)
                .foregroundStyle(sendDisabled ? Color.secondary : .white)
                .accessibilityLabel("Send message")
            }
            .padding(.leading, DS.Spacing.sm)
            .padding(.trailing, DS.Spacing.xs)
            .padding(.vertical, DS.Spacing.xs)
            .background(DS.ColorToken.surface, in: RoundedRectangle(cornerRadius: DS.Radius.sheet))
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.sheet)
                    .stroke(DS.ColorToken.separator.opacity(0.25), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 18, y: 8)
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.md)
        .padding(.bottom, DS.Spacing.lg)
        .background(.regularMaterial)
        .task(id: pickerItem) {
            guard let pickerItem else { return }
            do {
                if let data = try await pickerItem.loadTransferable(type: Data.self) {
                    viewModel.selectImageData(data)
                }
            } catch {
                viewModel.failImageSelection()
            }
        }
    }

    private var sendDisabled: Bool {
        viewModel.isLoading || (viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedImage == nil)
    }
}
