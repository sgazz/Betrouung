import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: CareProfileViewModel

    @State private var isPresentingAdd = false
    @State private var newName = ""

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                if viewModel.filteredProfiles.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(.secondary)
                        Text("No profiles yet")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        Text("Tap + to add your first care profile.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(viewModel.filteredProfiles) { profile in
                        NavigationLink {
                            ProfileDetailView(profile: profile)
                        } label: {
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
                                        .foregroundStyle(.accentColor)
                                    Text("\(profile.numberOfPeople) osoba")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                        }
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

            Button {
                newName = ""
                isPresentingAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
                    .frame(width: 56, height: 56)
                    .background(.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .accessibilityLabel("Dodaj profil")
        }
        .navigationTitle("Betreuung")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .automatic))
        .sheet(isPresented: $isPresentingAdd) {
            NavigationStack {
                Form {
                    Section("Ime") {
                        TextField("npr. Milica J.", text: $newName)
                            .textInputAutocapitalization(.words)
                    }
                }
                .navigationTitle("Novi profil")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Otkaži") { isPresentingAdd = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Sačuvaj") {
                            viewModel.addProfile(name: newName)
                            isPresentingAdd = false
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(viewModel: CareProfileViewModel(dataService: LocalDataService()))
    }
}

