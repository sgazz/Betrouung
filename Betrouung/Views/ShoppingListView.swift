import SwiftUI

struct ShoppingListView: View {
    let profile: CareProfile
    @Environment(\.appFlowAccent) private var accent

    @StateObject private var viewModel: ShoppingListViewModel
    @State private var newItemName = ""
    @State private var isShowingShoppingMode = false
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var suggestedItemsTitle: String {
        L10n.t("shopping.suggested_items", languageCode: selectedLanguageRaw)
    }

    private var noItemsText: String {
        L10n.t("shopping.no_items", languageCode: selectedLanguageRaw)
    }

    private var deleteText: String {
        L10n.t("shopping.delete", languageCode: selectedLanguageRaw)
    }

    private var screenTitle: String {
        L10n.t("shopping.title", languageCode: selectedLanguageRaw)
    }

    private var addItemPlaceholder: String {
        L10n.t("shopping.add_item_placeholder", languageCode: selectedLanguageRaw)
    }

    private var shoppingModeText: String {
        L10n.t("shopping.start_mode", languageCode: selectedLanguageRaw)
    }

    init(profile: CareProfile, dataService: any DataService) {
        self.profile = profile
        _viewModel = StateObject(wrappedValue: ShoppingListViewModel(profileId: profile.id, dataService: dataService))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            List {
                let suggestions = viewModel.getSuggestedItems()

                if !suggestions.isEmpty {
                    Section(suggestedItemsTitle) {
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
                                            .foregroundStyle(accent.primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .appGlassCard()
                                    }
                                    .buttonStyle(SecondaryCardButtonStyle())
                                    .frame(minHeight: 50)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                if viewModel.groupedItems.isEmpty {
                    ContentUnavailableView(noItemsText, systemImage: "cart.badge.plus")
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
                                        itemRow(item)
                                    }
                                    .buttonStyle(SecondaryCardButtonStyle())
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            withAnimation(.easeInOut(duration: 0.16)) {
                                                viewModel.deleteItem(itemId: item.id)
                                            }
                                            Haptics.lightTap()
                                        } label: {
                                            Label(deleteText, systemImage: "trash")
                                        }
                                    }
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AppBrandTitleView(title: "DailyCareCart")
            }
        }
        .safeAreaInset(edge: .bottom) {
            addItemBar
                .background(Color(.systemBackground).opacity(0.96))
        }
        .onAppear { viewModel.refresh() }
        .fullScreenCover(isPresented: $isShowingShoppingMode) {
            ShoppingModeView(viewModel: viewModel)
        }
    }

    private var addItemBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField(addItemPlaceholder, text: $newItemName)
                    .font(.body)
                    .appInputFieldStyle()
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

                VoiceInputButton(text: $newItemName)

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
                        .background(accent.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PrimaryCTAButtonStyle())
                .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Button {
                Haptics.lightTap()
                isShowingShoppingMode = true
            } label: {
                Label(shoppingModeText, systemImage: "cart.fill")
                    .font(.headline)
                    .foregroundStyle(accent.primary)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .appGlassCard()
            }
            .buttonStyle(SecondaryCardButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func itemRow(_ item: ShoppingItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(item.isChecked ? AppPalette.green : .secondary)
            Text(item.name)
                .font(.body)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(12)
        .frame(minHeight: 56)
        .appGlassCard()
        .contentShape(Rectangle())
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

