import SwiftUI

struct TypingIndicatorView: View {
    var label: String
    @State private var activeDot = 0

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            HStack(spacing: DS.Spacing.xs) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(.secondary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(activeDot == index ? 1.45 : 1)
                        .animation(.easeInOut(duration: 0.25), value: activeDot)
                }
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DS.Radius.bubble))
        .task {
            while !Task.isCancelled {
                for index in 0..<3 {
                    activeDot = index
                    try? await Task.sleep(for: .milliseconds(220))
                }
                try? await Task.sleep(for: .milliseconds(350))
            }
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    TypingIndicatorView(label: "Searching products...")
        .padding()
}
