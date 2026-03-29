import SwiftUI

struct CreateProfileView: View {
    @ObservedObject var profilesViewModel: CareProfileViewModel
    @StateObject private var formViewModel = CreateProfileFormViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var titleText: String { L10n.t("create_profile.title", languageCode: selectedLanguageRaw) }
    private var sectionBasicText: String { L10n.t("create_profile.section.basic", languageCode: selectedLanguageRaw) }
    private var sectionDetailsText: String { L10n.t("create_profile.section.details", languageCode: selectedLanguageRaw) }
    private var sectionNotesText: String { L10n.t("create_profile.section.notes", languageCode: selectedLanguageRaw) }
    private var namePlaceholderText: String { L10n.t("create_profile.name.placeholder", languageCode: selectedLanguageRaw) }
    private var addressPlaceholderText: String { L10n.t("create_profile.address.placeholder", languageCode: selectedLanguageRaw) }
    private var phonePlaceholderText: String { L10n.t("create_profile.phone.placeholder", languageCode: selectedLanguageRaw) }
    private var emailPlaceholderText: String { L10n.t("create_profile.email.placeholder", languageCode: selectedLanguageRaw) }
    private var guardianPlaceholderText: String { L10n.t("create_profile.guardian_contact.placeholder", languageCode: selectedLanguageRaw) }
    private var preferredStorePlaceholderText: String { L10n.t("create_profile.preferred_store.placeholder", languageCode: selectedLanguageRaw) }
    private var notesPlaceholderText: String { L10n.t("create_profile.notes.placeholder", languageCode: selectedLanguageRaw) }
    private var numberOfPeopleText: String { L10n.t("create_profile.number_of_people", languageCode: selectedLanguageRaw) }
    private var cancelText: String { L10n.t("common.cancel", languageCode: selectedLanguageRaw) }
    private var saveText: String { L10n.t("calendar.sheet.save", languageCode: selectedLanguageRaw) }

    private var validationMessage: String? {
        if let nameError = formViewModel.nameError(using: profilesViewModel) {
            switch nameError {
            case .empty:
                return L10n.t("create_profile.validation.empty_name", languageCode: selectedLanguageRaw)
            case .tooShort:
                return L10n.t("create_profile.validation.short_name", languageCode: selectedLanguageRaw)
            case .duplicate:
                return L10n.t("create_profile.validation.duplicate_name", languageCode: selectedLanguageRaw)
            }
        }
        if let phoneError = formViewModel.phoneError(using: profilesViewModel) {
            switch phoneError {
            case .empty:
                return L10n.t("create_profile.validation.empty_phone", languageCode: selectedLanguageRaw)
            case .invalid:
                return L10n.t("create_profile.validation.invalid_phone", languageCode: selectedLanguageRaw)
            }
        }
        if let emailError = formViewModel.emailError(using: profilesViewModel) {
            switch emailError {
            case .empty:
                return L10n.t("create_profile.validation.empty_email", languageCode: selectedLanguageRaw)
            case .invalid:
                return L10n.t("create_profile.validation.invalid_email", languageCode: selectedLanguageRaw)
            }
        }
        if let guardianError = formViewModel.guardianContactError(using: profilesViewModel) {
            switch guardianError {
            case .empty:
                return L10n.t("create_profile.validation.empty_guardian_contact", languageCode: selectedLanguageRaw)
            case .invalid:
                return nil
            }
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(sectionBasicText) {
                    HStack(spacing: 8) {
                        TextField(namePlaceholderText, text: $formViewModel.name)
                            .textInputAutocapitalization(.words)
                        VoiceInputButton(text: $formViewModel.name)
                    }

                    Stepper(value: $formViewModel.numberOfPeople, in: 1...10) {
                        Text("\(numberOfPeopleText): \(formViewModel.numberOfPeople)")
                    }
                }

                Section(sectionDetailsText) {
                    HStack(spacing: 8) {
                        TextField(addressPlaceholderText, text: $formViewModel.address)
                            .textInputAutocapitalization(.words)
                        VoiceInputButton(text: $formViewModel.address)
                    }

                    HStack(spacing: 8) {
                        TextField(phonePlaceholderText, text: $formViewModel.phone)
                            .keyboardType(.phonePad)
                            .textInputAutocapitalization(.never)
                        VoiceInputButton(text: $formViewModel.phone)
                    }

                    HStack(spacing: 8) {
                        TextField(emailPlaceholderText, text: $formViewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        VoiceInputButton(text: $formViewModel.email)
                    }

                    HStack(spacing: 8) {
                        TextField(guardianPlaceholderText, text: $formViewModel.guardianContact)
                            .textInputAutocapitalization(.words)
                        VoiceInputButton(text: $formViewModel.guardianContact)
                    }

                    HStack(spacing: 8) {
                        TextField(preferredStorePlaceholderText, text: $formViewModel.preferredStore)
                            .textInputAutocapitalization(.words)
                        VoiceInputButton(text: $formViewModel.preferredStore)
                    }
                }

                Section(sectionNotesText) {
                    HStack(alignment: .top, spacing: 8) {
                        TextField(notesPlaceholderText, text: $formViewModel.notes, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                        VoiceInputButton(text: $formViewModel.notes)
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(cancelText) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveText) {
                        let didSave = profilesViewModel.addProfile(
                            name: formViewModel.name,
                            address: formViewModel.address,
                            phone: formViewModel.phone,
                            email: formViewModel.email,
                            guardianContact: formViewModel.guardianContact,
                            numberOfPeople: formViewModel.numberOfPeople,
                            notes: formViewModel.notes,
                            preferredStore: formViewModel.preferredStore
                        )
                        if didSave {
                            dismiss()
                        }
                    }
                    .disabled(!formViewModel.canSave(using: profilesViewModel))
                }
            }
        }
        .presentationDetents([.large])
    }
}

#Preview {
    CreateProfileView(profilesViewModel: CareProfileViewModel(dataService: LocalDataService()))
}
