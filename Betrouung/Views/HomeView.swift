import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: CareProfileViewModel
    @EnvironmentObject private var container: AppContainer

    @State private var isPresentingAdd = false
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var noProfilesTitle: String {
        L10n.t("home.no_profiles_title", languageCode: selectedLanguageRaw)
    }

    private var noProfilesSubtitle: String {
        L10n.t("home.no_profiles_subtitle", languageCode: selectedLanguageRaw)
    }

    private var calendarText: String {
        L10n.t("home.calendar_reminders", languageCode: selectedLanguageRaw)
    }

    private var titleText: String {
        "DailyCareCart"
    }

    private var addProfileLabel: String {
        L10n.t("home.add_profile", languageCode: selectedLanguageRaw)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppBackgroundView()

            List {
                if viewModel.filteredProfiles.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(.secondary)
                        Text(noProfilesTitle)
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        Text(noProfilesSubtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .appGlassCard()
                    .frame(maxWidth: .infinity, minHeight: 260)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } else {
                    Section {
                        NavigationLink {
                            CalendarView(dataService: container.dataService)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "calendar")
                                    .foregroundStyle(AppPalette.orange)
                                Text(calendarText)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                            .appGlassCard()
                        }
                        .buttonStyle(SecondaryCardButtonStyle())
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }

                    ForEach(viewModel.filteredProfiles) { profile in
                        NavigationLink {
                            ProfileDetailView(profile: profile, profilesViewModel: viewModel) { updated in
                                viewModel.updateProfile(updated)
                            }
                        } label: {
                            profileCard(profile)
                        }
                        .buttonStyle(SecondaryCardButtonStyle())
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .accessibilityHint("Otvori detalje profila")
                    }
                    .onDelete { indexSet in
                        let visible = viewModel.filteredProfiles
                        for index in indexSet {
                            viewModel.deleteProfile(id: visible[index].id)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            Button {
                isPresentingAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
                    .frame(width: 56, height: 56)
                    .background(AppPalette.orange)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .accessibilityLabel(addProfileLabel)
        }
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AppBrandTitleView(title: titleText)
            }
        }
        .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .automatic))
        .sheet(isPresented: $isPresentingAdd) {
            CreateProfileView(profilesViewModel: viewModel)
        }
    }

    private func profileCard(_ profile: CareProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(profile.name)
                .font(.body.weight(.bold))
                .foregroundStyle(.primary)

            Text(profile.address.isEmpty ? "Adresa nije uneta" : profile.address)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(AppPalette.green)
                Text("\(profile.numberOfPeople) osoba")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .appGlassCard()
    }
}

#Preview {
    let container = AppContainer()
    let viewModel = CareProfileViewModel(dataService: container.dataService)
    return NavigationStack {
        HomeView(viewModel: viewModel)
            .environmentObject(container)
    }
}

