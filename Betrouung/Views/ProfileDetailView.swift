import SwiftUI

struct ProfileDetailView: View {
    let profile: CareProfile
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                profileHeaderCard

                VStack(alignment: .leading, spacing: 12) {
                    Text("Actions")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    NavigationLink {
                        ShoppingListView(profile: profile, dataService: container.dataService)
                    } label: {
                        actionButtonLabel(title: "Shopping List", icon: "checklist")
                    }

                    NavigationLink {
                        NearbyStoresView(profile: profile)
                    } label: {
                        actionButtonLabel(title: "Nearby Stores", icon: "mappin.and.ellipse")
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private var profileHeaderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(profile.name)
                .font(.title2.bold())
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                Image(systemName: "house")
                    .foregroundStyle(.secondary)
                Text(profile.address.isEmpty ? "Adresa nije uneta" : profile.address)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(profile.notes.isEmpty ? "Nema dodatnih napomena." : profile.notes)
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
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func actionButtonLabel(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(Color.accentColor)
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
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        ProfileDetailView(profile: MockData.profiles[0])
            .environmentObject(AppContainer())
    }
}

