import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    private var isUser: Bool {
        message.role == "user"
    }

    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 48) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: DS.Spacing.xs) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(isUser ? .white : DS.ColorToken.primaryText)
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.vertical, DS.Spacing.md)
                    .background(bubbleBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.bubble, style: .continuous))
                    .textSelection(.enabled)
                    .frame(maxWidth: 620, alignment: isUser ? .trailing : .leading)

                Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DS.Spacing.xs)
            }
            .accessibilityElement(children: .combine)

            if !isUser { Spacer(minLength: 48) }
        }
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            Color.accentColor
        } else {
            Rectangle().fill(.ultraThinMaterial)
        }
    }
}
