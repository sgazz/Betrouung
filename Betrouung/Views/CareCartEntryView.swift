import SwiftUI

/// Ulazni ekran posle prijave: Care ili Cart vode na isti Home tok.
struct CareCartEntryView: View {
    let onContinue: () -> Void

    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var careTitle: String {
        L10n.t("care_cart.care", languageCode: selectedLanguageRaw)
    }

    private var cartTitle: String {
        L10n.t("care_cart.cart", languageCode: selectedLanguageRaw)
    }

    private var subtitleText: String {
        L10n.t("care_cart.subtitle", languageCode: selectedLanguageRaw)
    }

    private var brandTitle: String {
        "DailyCareCart"
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 24) {
                Spacer(minLength: 20)

                AppBrandTitleView(title: brandTitle)
                    .padding(.bottom, 4)

                Text(subtitleText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(spacing: 16) {
                    entryButton(
                        title: careTitle,
                        icon: "heart.text.square.fill",
                        color: AppPalette.green
                    ) {
                        onContinue()
                    }

                    entryButton(
                        title: cartTitle,
                        icon: "cart.fill",
                        color: AppPalette.orange
                    ) {
                        onContinue()
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 28)
            }
        }
    }

    private func entryButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title2.bold())
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .opacity(0.9)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PrimaryCTAButtonStyle())
    }
}

#Preview {
    CareCartEntryView {}
}
