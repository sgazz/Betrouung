import SwiftUI

struct ShoppingModeView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var finishText: String {
        L10n.t("shoppingmode.finish", languageCode: selectedLanguageRaw)
    }

    private var displayItems: [ShoppingItem] {
        viewModel.items.sorted { lhs, rhs in
            if lhs.isChecked == rhs.isChecked {
                return lhs.createdAt < rhs.createdAt
            }
            return !lhs.isChecked && rhs.isChecked
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, AppPalette.orange.opacity(0.35), Color(.darkGray)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(displayItems) { item in
                        Button {
                            withAnimation(.easeInOut(duration: 0.16)) {
                                viewModel.toggleIsChecked(itemId: item.id)
                            }
                            Haptics.lightTap()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(item.isChecked ? AppPalette.green : .white)

                                Text(item.name)
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .strikethrough(item.isChecked, color: AppPalette.green)
                                    .multilineTextAlignment(.leading)

                                Spacer()
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.11), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(SecondaryCardButtonStyle())
                        .frame(maxWidth: .infinity, minHeight: 92)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                Haptics.softSuccess()
                dismiss()
            } label: {
                Label(finishText, systemImage: "checkmark")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(AppPalette.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PrimaryCTAButtonStyle())
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 10)
            .background(Color.black.opacity(0.92))
        }
        .onAppear { viewModel.refresh() }
        .animation(.easeInOut(duration: 0.18), value: displayItems.map(\.id))
    }
}

#Preview {
    let dataService = MockData.makeLocalDataServiceForPreviews()
    let vm = ShoppingListViewModel(profileId: MockData.profiles[0].id, dataService: dataService)
    return ShoppingModeView(viewModel: vm)
}

