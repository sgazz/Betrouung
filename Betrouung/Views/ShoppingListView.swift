import SwiftUI

struct ShoppingListView: View {
    let profile: CareProfile

    @StateObject private var viewModel: ShoppingListViewModel
    @State private var newItemName = ""
    @State private var isShowingShoppingMode = false

    init(profile: CareProfile, dataService: any DataService) {
        self.profile = profile
        _viewModel = StateObject(wrappedValue: ShoppingListViewModel(profileId: profile.id, dataService: dataService))
    }

    var body: some View {
        List {
            let suggestions = viewModel.getSuggestedItems()

            if !suggestions.isEmpty {
                Section("Suggested items") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.18)) {
                                        viewModel.addItem(name: suggestion, category: .Lebensmittel)
                                    }
                                    Haptics.lightTap()
                                } label: {
                                    Label(suggestion.capitalized, systemImage: "plus.circle.fill")
                                        .font(.headline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(.secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(PressableButtonStyle())
                                .frame(minHeight: 50)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }

            if viewModel.groupedItems.isEmpty {
                ContentUnavailableView("Nema stavki", systemImage: "cart.badge.plus")
                    .frame(maxWidth: .infinity, minHeight: 220)
            } else {
                ForEach(ShoppingItemCategory.allCases, id: \.self) { category in
                    let categoryItems = viewModel.groupedItems[category] ?? []
                    if !categoryItems.isEmpty {
                        Section(category.rawValue) {
                            ForEach(categoryItems) { item in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.16)) {
                                        viewModel.toggleIsChecked(itemId: item.id)
                                    }
                                    Haptics.lightTap()
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(item.isChecked ? .accentColor : .secondary)
                                        Text(item.name)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .frame(minHeight: 56)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PressableButtonStyle())
                                .swipeActions {
                                    Button(role: .destructive) {
                                        withAnimation(.easeInOut(duration: 0.16)) {
                                            viewModel.deleteItem(itemId: item.id)
                                        }
                                        Haptics.lightTap()
                                    } label: {
                                        Label("Obriši", systemImage: "trash")
                                    }
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Kupovina")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            addItemBar
                .background(.ultraThinMaterial)
        }
        .onAppear { viewModel.refresh() }
        .fullScreenCover(isPresented: $isShowingShoppingMode) {
            ShoppingModeView(viewModel: viewModel)
        }
    }

    private var addItemBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField("Add item...", text: $newItemName)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .frame(minHeight: 50)
                    .submitLabel(.done)
                    .onSubmit {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            viewModel.addItem(name: newItemName, category: .Lebensmittel)
                        }
                        if !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Haptics.softSuccess()
                        }
                        newItemName = ""
                    }

                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        viewModel.addItem(name: newItemName, category: .Lebensmittel)
                    }
                    Haptics.softSuccess()
                    newItemName = ""
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .frame(width: 50, height: 50)
                        .background(.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Button {
                Haptics.lightTap()
                isShowingShoppingMode = true
            } label: {
                Label("Start Shopping Mode", systemImage: "cart.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

#Preview {
    NavigationStack {
        ShoppingListView(
            profile: MockData.profiles[0],
            dataService: MockData.makeLocalDataServiceForPreviews()
        )
    }
}

