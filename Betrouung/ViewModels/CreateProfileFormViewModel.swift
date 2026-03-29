import Combine
import Foundation

@MainActor
final class CreateProfileFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var address: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var guardianContact: String = ""
    @Published var numberOfPeople: Int = 1
    @Published var notes: String = ""
    @Published var preferredStore: String = ""

    func nameError(using profilesViewModel: CareProfileViewModel) -> CareProfileViewModel.CreateProfileNameError? {
        profilesViewModel.validateProfileName(name)
    }

    func phoneError(using profilesViewModel: CareProfileViewModel) -> CareProfileViewModel.ContactFieldError? {
        profilesViewModel.validatePhone(phone)
    }

    func emailError(using profilesViewModel: CareProfileViewModel) -> CareProfileViewModel.ContactFieldError? {
        profilesViewModel.validateEmail(email)
    }

    func guardianContactError(using profilesViewModel: CareProfileViewModel) -> CareProfileViewModel.ContactFieldError? {
        profilesViewModel.validateGuardianContact(guardianContact)
    }

    func canSave(using profilesViewModel: CareProfileViewModel) -> Bool {
        nameError(using: profilesViewModel) == nil &&
        phoneError(using: profilesViewModel) == nil &&
        emailError(using: profilesViewModel) == nil &&
        guardianContactError(using: profilesViewModel) == nil
    }
}
