import Combine
import Foundation

@MainActor
final class CreateProfileFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var address: String = ""
    @Published var numberOfPeople: Int = 1
    @Published var notes: String = ""
    @Published var preferredStore: String = ""

    func nameError(using profilesViewModel: CareProfileViewModel) -> CareProfileViewModel.CreateProfileNameError? {
        profilesViewModel.validateProfileName(name)
    }

    func canSave(using profilesViewModel: CareProfileViewModel) -> Bool {
        nameError(using: profilesViewModel) == nil
    }
}
