import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void
    @State private var iconScale = 0.3
    @State private var showTitle = false
    @State private var showTagline = false
    @State private var opacity = 1.0

    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "cart.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)
                .scaleEffect(iconScale)

            Text("AI Shopping")
                .font(.largeTitle.bold())
                .opacity(showTitle ? 1 : 0)

            Text("Find, compare & buy with AI")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .opacity(showTagline ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .opacity(opacity)
        .task {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1
            }
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.easeIn(duration: 0.25)) { showTitle = true }
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.easeIn(duration: 0.25)) { showTagline = true }
            try? await Task.sleep(for: .milliseconds(900))
            withAnimation(.easeOut(duration: 0.4)) { opacity = 0 }
            try? await Task.sleep(for: .milliseconds(400))
            onFinish()
        }
    }
}
