import SwiftUI

struct ProfileDetailView: View {
    let profile: CareProfile
    @EnvironmentObject private var container: AppContainer
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var actionsTitle: String {
        L10n.t("profile.actions", languageCode: selectedLanguageRaw)
    }

    private var shoppingListText: String {
        L10n.t("profile.shopping_list", languageCode: selectedLanguageRaw)
    }

    private var nearbyStoresText: String {
        L10n.t("profile.nearby_stores", languageCode: selectedLanguageRaw)
    }

    private var notesTitle: String {
        L10n.t("profile.notes", languageCode: selectedLanguageRaw)
    }

    private var emptyAddressText: String {
        L10n.t("profile.address_not_provided", languageCode: selectedLanguageRaw)
    }

    private var emptyNotesText: String {
        L10n.t("profile.no_notes", languageCode: selectedLanguageRaw)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    profileHeaderCard

                    VStack(alignment: .leading, spacing: 12) {
                        AppSectionHeader(title: actionsTitle)

                        NavigationLink {
                            ShoppingListView(profile: profile, dataService: container.dataService)
                        } label: {
                            actionButtonLabel(title: shoppingListText, icon: "checklist")
                        }
                        .buttonStyle(SecondaryCardButtonStyle())

                        NavigationLink {
                            NearbyStoresView(profile: profile)
                        } label: {
                            actionButtonLabel(title: nearbyStoresText, icon: "mappin.and.ellipse")
                        }
                        .buttonStyle(SecondaryCardButtonStyle())
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AppBrandTitleView(title: "DailyCareCart")
            }
        }
    }

    private var profileHeaderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(profile.name)
                .font(.title2.bold())
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                Image(systemName: "house")
                    .foregroundStyle(.secondary)
                Text(profile.address.isEmpty ? emptyAddressText : profile.address)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(notesTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(profile.notes.isEmpty ? emptyNotesText : profile.notes)
                    .font(.body)
                    .foregroundStyle(.primary)
            }

            HStack(spacing: 8) {
                Image(systemName: "person.2")
                    .foregroundStyle(.secondary)
                Text("\(profile.numberOfPeople) osoba")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appGlassCard()
    }

    private func actionButtonLabel(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(AppPalette.orange)
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .appGlassCard()
    }
}

#Preview {
    NavigationStack {
        ProfileDetailView(profile: MockData.profiles[0])
            .environmentObject(AppContainer())
    }
}

