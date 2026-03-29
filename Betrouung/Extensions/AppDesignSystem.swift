import SwiftUI

enum AppPalette {
    static let orange = Color.orange
    static let green = Color.green
    static let red = Color.red
}

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    AppPalette.orange.opacity(0.06),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(AppPalette.orange.opacity(0.16))
                .frame(width: 260, height: 260)
                .offset(x: -110, y: -250)

            Circle()
                .fill(AppPalette.green.opacity(0.12))
                .frame(width: 220, height: 220)
                .offset(x: 120, y: 260)
        }
    }
}

struct AppGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Color(.secondarySystemBackground).opacity(0.94),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

struct PrimaryCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct SecondaryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .opacity(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeInOut(duration: 0.14), value: configuration.isPressed)
    }
}

struct AppSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AppBrandTitleView: View {
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

struct AppInputFieldModifier: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        content
            .padding(12)
            .frame(minHeight: 50)
            .background(Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? AppPalette.orange.opacity(0.75) : Color.clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .animation(.easeInOut(duration: 0.16), value: isFocused)
    }
}

extension View {
    func appGlassCard() -> some View {
        modifier(AppGlassCardModifier())
    }

    func appInputFieldStyle(isFocused: Bool = false) -> some View {
        modifier(AppInputFieldModifier(isFocused: isFocused))
    }
}
