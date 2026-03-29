import SwiftUI

struct ProfileDetailView: View {
    let onSaveProfile: (CareProfile) -> Void
    @ObservedObject var profilesViewModel: CareProfileViewModel
    @EnvironmentObject private var container: AppContainer
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue
    @State private var profile: CareProfile
    @State private var isPresentingEdit = false

    init(profile: CareProfile, profilesViewModel: CareProfileViewModel, onSaveProfile: @escaping (CareProfile) -> Void = { _ in }) {
        self.onSaveProfile = onSaveProfile
        self.profilesViewModel = profilesViewModel
        _profile = State(initialValue: profile)
    }

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

    private var contactsTitle: String {
        L10n.t("profile.contacts", languageCode: selectedLanguageRaw)
    }

    private var emptyAddressText: String {
        L10n.t("profile.address_not_provided", languageCode: selectedLanguageRaw)
    }

    private var emptyNotesText: String {
        L10n.t("profile.no_notes", languageCode: selectedLanguageRaw)
    }

    private var emptyPhoneText: String {
        L10n.t("profile.phone_not_provided", languageCode: selectedLanguageRaw)
    }

    private var emptyEmailText: String {
        L10n.t("profile.email_not_provided", languageCode: selectedLanguageRaw)
    }

    private var emptyGuardianText: String {
        L10n.t("profile.guardian_not_provided", languageCode: selectedLanguageRaw)
    }

    private var editText: String {
        L10n.t("profile.edit", languageCode: selectedLanguageRaw)
    }

    private var saveText: String {
        L10n.t("calendar.sheet.save", languageCode: selectedLanguageRaw)
    }

    private var cancelText: String {
        L10n.t("common.cancel", languageCode: selectedLanguageRaw)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(editText) {
                    isPresentingEdit = true
                }
            }
        }
        .sheet(isPresented: $isPresentingEdit) {
            EditProfileSheet(
                profilesViewModel: profilesViewModel,
                initialProfile: profile,
                saveText: saveText,
                cancelText: cancelText
            ) { updated in
                profile = updated
                onSaveProfile(updated)
            }
        }
    }

    private var profileHeaderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(profile.name)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Text(contactsTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                phoneRow
                emailRow

                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .foregroundStyle(.secondary)
                    Text(profile.guardianContact.isEmpty ? emptyGuardianText : profile.guardianContact)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }

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
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appGlassCard()
    }

    @ViewBuilder
    private var phoneRow: some View {
        let phone = profile.phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let telDigits = phone.filter { $0.isNumber || $0 == "+" }
        HStack(spacing: 8) {
            Image(systemName: "phone")
                .foregroundStyle(.secondary)
            if telDigits.count >= 6, let url = URL(string: "tel:\(telDigits)") {
                Link(phone.isEmpty ? emptyPhoneText : phone, destination: url)
                    .font(.body)
                    .foregroundStyle(AppPalette.orange)
            } else {
                Text(phone.isEmpty ? emptyPhoneText : phone)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
    }

    @ViewBuilder
    private var emailRow: some View {
        let email = profile.email.trimmingCharacters(in: .whitespacesAndNewlines)
        HStack(spacing: 8) {
            Image(systemName: "envelope")
                .foregroundStyle(.secondary)
            if !email.isEmpty, email.contains("@"), let url = URL(string: "mailto:\(email)") {
                Link(email, destination: url)
                    .font(.body)
                    .foregroundStyle(AppPalette.orange)
            } else {
                Text(email.isEmpty ? emptyEmailText : email)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
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

private struct EditProfileSheet: View {
    @ObservedObject var profilesViewModel: CareProfileViewModel
    let initialProfile: CareProfile
    let saveText: String
    let cancelText: String
    let onSave: (CareProfile) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var address: String
    @State private var notes: String
    @State private var phone: String
    @State private var email: String
    @State private var guardianContact: String
    @State private var confirmDiscard = false
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    init(
        profilesViewModel: CareProfileViewModel,
        initialProfile: CareProfile,
        saveText: String,
        cancelText: String,
        onSave: @escaping (CareProfile) -> Void
    ) {
        self.profilesViewModel = profilesViewModel
        self.initialProfile = initialProfile
        self.saveText = saveText
        self.cancelText = cancelText
        self.onSave = onSave
        _name = State(initialValue: initialProfile.name)
        _address = State(initialValue: initialProfile.address)
        _notes = State(initialValue: initialProfile.notes)
        _phone = State(initialValue: initialProfile.phone)
        _email = State(initialValue: initialProfile.email)
        _guardianContact = State(initialValue: initialProfile.guardianContact)
    }

    private var titleText: String {
        L10n.t("profile.edit_title", languageCode: selectedLanguageRaw)
    }

    private var sectionBasicText: String {
        L10n.t("create_profile.section.basic", languageCode: selectedLanguageRaw)
    }

    private var contactsSectionTitle: String {
        L10n.t("profile.contacts", languageCode: selectedLanguageRaw)
    }

    private var namePlaceholder: String {
        L10n.t("create_profile.name.placeholder", languageCode: selectedLanguageRaw)
    }

    private var addressPlaceholder: String {
        L10n.t("create_profile.address.placeholder", languageCode: selectedLanguageRaw)
    }

    private var phonePlaceholder: String {
        L10n.t("create_profile.phone.placeholder", languageCode: selectedLanguageRaw)
    }

    private var emailPlaceholder: String {
        L10n.t("create_profile.email.placeholder", languageCode: selectedLanguageRaw)
    }

    private var guardianPlaceholder: String {
        L10n.t("create_profile.guardian_contact.placeholder", languageCode: selectedLanguageRaw)
    }

    private var notesPlaceholder: String {
        L10n.t("create_profile.notes.placeholder", languageCode: selectedLanguageRaw)
    }

    private var notesSectionTitle: String {
        L10n.t("profile.edit.notes_title", languageCode: selectedLanguageRaw)
    }

    private var unsavedTitle: String {
        L10n.t("profile.edit.unsaved_title", languageCode: selectedLanguageRaw)
    }

    private var unsavedMessage: String {
        L10n.t("profile.edit.unsaved_message", languageCode: selectedLanguageRaw)
    }

    private var discardText: String {
        L10n.t("profile.edit.discard", languageCode: selectedLanguageRaw)
    }

    private var keepEditingText: String {
        L10n.t("profile.edit.keep_editing", languageCode: selectedLanguageRaw)
    }

    private var isDirty: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines) != initialProfile.name.trimmingCharacters(in: .whitespacesAndNewlines)
            || address.trimmingCharacters(in: .whitespacesAndNewlines) != initialProfile.address.trimmingCharacters(in: .whitespacesAndNewlines)
            || notes.trimmingCharacters(in: .whitespacesAndNewlines) != initialProfile.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            || phone.trimmingCharacters(in: .whitespacesAndNewlines) != initialProfile.phone.trimmingCharacters(in: .whitespacesAndNewlines)
            || email.trimmingCharacters(in: .whitespacesAndNewlines) != initialProfile.email.trimmingCharacters(in: .whitespacesAndNewlines)
            || guardianContact.trimmingCharacters(in: .whitespacesAndNewlines) != initialProfile.guardianContact.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var validationMessage: String? {
        if let nameError = profilesViewModel.validateProfileName(name, excludingProfileId: initialProfile.id) {
            switch nameError {
            case .empty:
                return L10n.t("create_profile.validation.empty_name", languageCode: selectedLanguageRaw)
            case .tooShort:
                return L10n.t("create_profile.validation.short_name", languageCode: selectedLanguageRaw)
            case .duplicate:
                return L10n.t("create_profile.validation.duplicate_name", languageCode: selectedLanguageRaw)
            }
        }
        if let phoneError = profilesViewModel.validatePhone(phone) {
            switch phoneError {
            case .empty:
                return L10n.t("create_profile.validation.empty_phone", languageCode: selectedLanguageRaw)
            case .invalid:
                return L10n.t("create_profile.validation.invalid_phone", languageCode: selectedLanguageRaw)
            }
        }
        if let emailError = profilesViewModel.validateEmail(email) {
            switch emailError {
            case .empty:
                return L10n.t("create_profile.validation.empty_email", languageCode: selectedLanguageRaw)
            case .invalid:
                return L10n.t("create_profile.validation.invalid_email", languageCode: selectedLanguageRaw)
            }
        }
        if let guardianError = profilesViewModel.validateGuardianContact(guardianContact) {
            switch guardianError {
            case .empty:
                return L10n.t("create_profile.validation.empty_guardian_contact", languageCode: selectedLanguageRaw)
            case .invalid:
                return nil
            }
        }
        return nil
    }

    private var canSave: Bool {
        profilesViewModel.validateProfileName(name, excludingProfileId: initialProfile.id) == nil
            && profilesViewModel.validatePhone(phone) == nil
            && profilesViewModel.validateEmail(email) == nil
            && profilesViewModel.validateGuardianContact(guardianContact) == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(sectionBasicText) {
                    HStack(spacing: 8) {
                        TextField(namePlaceholder, text: $name)
                            .textInputAutocapitalization(.words)
                        VoiceInputButton(text: $name)
                    }
                    HStack(spacing: 8) {
                        TextField(addressPlaceholder, text: $address)
                            .textInputAutocapitalization(.words)
                        VoiceInputButton(text: $address)
                    }
                }

                Section(contactsSectionTitle) {
                    HStack(spacing: 8) {
                        TextField(phonePlaceholder, text: $phone)
                            .keyboardType(.phonePad)
                            .textInputAutocapitalization(.never)
                        VoiceInputButton(text: $phone)
                    }
                    HStack(spacing: 8) {
                        TextField(emailPlaceholder, text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        VoiceInputButton(text: $email)
                    }
                    HStack(spacing: 8) {
                        TextField(guardianPlaceholder, text: $guardianContact)
                            .textInputAutocapitalization(.words)
                        VoiceInputButton(text: $guardianContact)
                    }
                }

                Section(notesSectionTitle) {
                    HStack(alignment: .top, spacing: 8) {
                        ZStack(alignment: .topLeading) {
                            if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(notesPlaceholder)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                            TextEditor(text: $notes)
                                .frame(minHeight: 120)
                        }
                        VoiceInputButton(text: $notes)
                    }
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .font(.footnote)
                            .foregroundStyle(AppPalette.red)
                    }
                }
            }
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(isDirty)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cancelText) {
                        cancelTapped()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveText) {
                        saveTapped()
                    }
                    .disabled(!canSave)
                }
            }
            .confirmationDialog(
                unsavedTitle,
                isPresented: $confirmDiscard,
                titleVisibility: .visible
            ) {
                Button(discardText, role: .destructive) {
                    dismiss()
                }
                Button(keepEditingText, role: .cancel) {}
            } message: {
                Text(unsavedMessage)
            }
        }
        .presentationDetents([.large])
    }

    private func cancelTapped() {
        if isDirty {
            confirmDiscard = true
        } else {
            dismiss()
        }
    }

    private func saveTapped() {
        let updated = CareProfile(
            id: initialProfile.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            guardianContact: guardianContact.trimmingCharacters(in: .whitespacesAndNewlines),
            numberOfPeople: initialProfile.numberOfPeople,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            preferredStore: initialProfile.preferredStore
        )
        onSave(updated)
        dismiss()
    }
}

#Preview {
    let vm = CareProfileViewModel(dataService: LocalDataService())
    NavigationStack {
        ProfileDetailView(profile: MockData.profiles[0], profilesViewModel: vm)
            .environmentObject(AppContainer())
    }
}
