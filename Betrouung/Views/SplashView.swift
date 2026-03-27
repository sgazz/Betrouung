import SwiftUI

struct SplashView: View {
    let onContinue: () -> Void
    @State private var animate = false
    @State private var sloganIndex = 0
    @State private var isShowingInfoSheet = false
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var slogans: [String] {
        [
            L10n.t("splash.slogan.1", languageCode: selectedLanguageRaw),
            L10n.t("splash.slogan.2", languageCode: selectedLanguageRaw),
            L10n.t("splash.slogan.3", languageCode: selectedLanguageRaw),
        ]
    }

    private var tapToContinueText: String {
        L10n.t("splash.tap_continue", languageCode: selectedLanguageRaw)
    }

    private var infoButtonText: String {
        L10n.t("splash.info_button", languageCode: selectedLanguageRaw)
    }

    private var infoNavTitle: String {
        L10n.t("splash.info_nav_title", languageCode: selectedLanguageRaw)
    }

    private var gotItText: String {
        L10n.t("common.got_it", languageCode: selectedLanguageRaw)
    }

    private var infoParagraphs: (subtitle: String, intro: String, withAppText: String, bullets: String, oneHand: String, outro: String) {
        (
            L10n.t("info.subtitle", languageCode: selectedLanguageRaw),
            L10n.t("info.intro", languageCode: selectedLanguageRaw),
            L10n.t("info.with_app", languageCode: selectedLanguageRaw),
            L10n.t("info.bullets", languageCode: selectedLanguageRaw),
            L10n.t("info.one_hand", languageCode: selectedLanguageRaw),
            L10n.t("info.outro", languageCode: selectedLanguageRaw)
        )
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
                .contentShape(Rectangle())
                .onTapGesture {
                    onContinue()
                }

            VStack(spacing: 20) {
                VStack(spacing: 14) {
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .shadow(color: AppPalette.orange.opacity(0.2), radius: 12, x: 0, y: 8)
                    .scaleEffect(animate ? 1 : 0.94)

                    Text("DailyCareCart")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(slogans[sloganIndex])
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .appGlassCard()

                Text(tapToContinueText)
                    .font(.headline)
                    .foregroundStyle(AppPalette.orange)
                    .opacity(animate ? 1.0 : 0.7)

                Picker("Language", selection: $selectedLanguageRaw) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.shortLabel).tag(language.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)
                .onChange(of: selectedLanguageRaw) { _, _ in
                    sloganIndex = 0
                }

                Button {
                    isShowingInfoSheet = true
                } label: {
                    Label(infoButtonText, systemImage: "info.circle")
                        .font(.headline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground), in: Capsule(style: .continuous))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(PrimaryCTAButtonStyle())
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
        .task {
            while true {
                try? await Task.sleep(nanoseconds: 2_200_000_000)
                withAnimation(.easeInOut(duration: 0.35)) {
                    sloganIndex = (sloganIndex + 1) % slogans.count
                }
            }
        }
        .sheet(isPresented: $isShowingInfoSheet) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DailyCareCart")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)

                        Text(infoParagraphs.subtitle)
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text(infoParagraphs.intro)
                            .font(.body)
                            .foregroundStyle(.primary)

                        Text(infoParagraphs.withAppText)
                            .font(.headline)
                            .padding(.top, 6)

                        Text(infoParagraphs.bullets)
                            .font(.body)
                            .foregroundStyle(.primary)

                        Text(infoParagraphs.oneHand)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)

                        Text(infoParagraphs.outro)
                            .font(.headline)
                            .foregroundStyle(AppPalette.green)
                            .padding(.top, 4)

                        Button(gotItText) {
                            isShowingInfoSheet = false
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(AppPalette.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .buttonStyle(PrimaryCTAButtonStyle())
                        .padding(.top, 12)
                    }
                    .padding(16)
                }
                .navigationTitle(infoNavTitle)
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    SplashView(onContinue: {})
}
