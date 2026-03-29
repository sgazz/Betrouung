import SwiftUI

enum AppPalette {
    static let orange = Color.orange
    static let green = Color.green
    static let red = Color.red
}

/// Tema nakon izbora Care (zelena) ili Cart (narandžasta); neutral za splash/login/CareCart ulaz.
enum AppFlowAccent: Hashable {
    case neutral
    case care
    case cart

    /// Primarni akcent (FAB, fokus polja, ikone akcija, linkovi).
    var primary: Color {
        switch self {
        case .neutral, .cart:
            return AppPalette.orange
        case .care:
            return AppPalette.green
        }
    }

    /// Sekundarni akcent za varijacije (npr. druga nijansa u pozadini).
    var secondary: Color {
        switch self {
        case .neutral, .care:
            return AppPalette.green
        case .cart:
            return AppPalette.orange
        }
    }

    var gradientMid: Color {
        switch self {
        case .neutral:
            return AppPalette.orange.opacity(0.06)
        case .care:
            return AppPalette.green.opacity(0.08)
        case .cart:
            return AppPalette.orange.opacity(0.1)
        }
    }

    var orbTopLeading: Color {
        switch self {
        case .neutral:
            return AppPalette.orange.opacity(0.16)
        case .care:
            return AppPalette.green.opacity(0.18)
        case .cart:
            return AppPalette.orange.opacity(0.2)
        }
    }

    var orbBottomTrailing: Color {
        switch self {
        case .neutral:
            return AppPalette.green.opacity(0.12)
        case .care:
            return AppPalette.green.opacity(0.1)
        case .cart:
            return AppPalette.orange.opacity(0.09)
        }
    }

    /// Slika za blagi vodeni žig u pozadini (samo Care / Cart).
    var backgroundWatermarkAssetName: String? {
        switch self {
        case .neutral:
            return nil
        case .care:
            return "FlowModeCareWatermark"
        case .cart:
            return "FlowModeCartWatermark"
        }
    }
}

private struct AppFlowAccentKey: EnvironmentKey {
    static let defaultValue: AppFlowAccent = .neutral
}

extension EnvironmentValues {
    var appFlowAccent: AppFlowAccent {
        get { self[AppFlowAccentKey.self] }
        set { self[AppFlowAccentKey.self] = newValue }
    }
}

struct AppBackgroundView: View {
    @Environment(\.appFlowAccent) private var accent
    @Environment(\.colorScheme) private var colorScheme

    /// Vodeni žig kao „wireframe“: template-rendering boji linije kontura (izgled obrisa, bez punila).
    private var watermarkAlpha: Double {
        colorScheme == .dark ? 0.22 : 0.12
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    accent.gradientMid,
                    Color(.secondarySystemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(accent.orbTopLeading)
                .frame(width: 260, height: 260)
                .offset(x: -110, y: -250)

            Circle()
                .fill(accent.orbBottomTrailing)
                .frame(width: 220, height: 220)
                .offset(x: 120, y: 260)

            if let watermarkName = accent.backgroundWatermarkAssetName {
                GeometryReader { geo in
                    Image(watermarkName)
                        .renderingMode(.template)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: min(geo.size.width * 0.62, 340), height: min(geo.size.height * 0.38, 320))
                        .foregroundStyle(accent.primary.opacity(watermarkAlpha))
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.58)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
            }
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
    @Environment(\.appFlowAccent) private var accent
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var modeTagline: String? {
        switch accent {
        case .neutral:
            return nil
        case .care:
            return L10n.t("brand.mode_care", languageCode: selectedLanguageRaw)
        case .cart:
            return L10n.t("brand.mode_cart", languageCode: selectedLanguageRaw)
        }
    }

    private var accessibilityTitle: String {
        if let modeTagline {
            return "\(title), \(modeTagline)"
        }
        return title
    }

    var body: some View {
        VStack(spacing: 2) {
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
            if let modeTagline {
                Text(modeTagline)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent.primary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityTitle)
    }
}

struct AppInputFieldModifier: ViewModifier {
    @Environment(\.appFlowAccent) private var accent
    let isFocused: Bool

    func body(content: Content) -> some View {
        content
            .padding(12)
            .frame(minHeight: 50)
            .background(Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? accent.primary.opacity(0.75) : Color.clear, lineWidth: 1.5)
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
