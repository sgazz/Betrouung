import Combine
import Foundation

@MainActor
final class CareProfileViewModel: ObservableObject {
    enum CreateProfileNameError {
        case empty
        case tooShort
        case duplicate
    }

    enum ContactFieldError {
        case empty
        case invalid
    }

    @Published private(set) var profiles: [CareProfile] = []
    @Published var query: String = ""
    
    private let dataService: any DataService

    init(dataService: any DataService) {
        self.dataService = dataService
        profiles = dataService.fetchCareProfiles()
    }

    var filteredProfiles: [CareProfile] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return profiles }
        return profiles.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    func addProfile(name: String) {
        _ = addProfile(
            name: name,
            address: "",
            phone: "",
            email: "",
            guardianContact: "",
            numberOfPeople: 1,
            notes: "",
            preferredStore: nil
        )
    }

    @discardableResult
    func addProfile(
        name: String,
        address: String,
        phone: String,
        email: String,
        guardianContact: String,
        numberOfPeople: Int,
        notes: String,
        preferredStore: String?
    ) -> Bool {
        guard validateProfileName(name) == nil else { return false }
        guard validatePhone(phone) == nil else { return false }
        guard validateEmail(email) == nil else { return false }
        guard validateGuardianContact(guardianContact) == nil else { return false }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGuardianContact = guardianContact.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPreferredStore = preferredStore?.trimmingCharacters(in: .whitespacesAndNewlines)
        profiles.insert(
            CareProfile(
                name: trimmed,
                address: trimmedAddress,
                phone: trimmedPhone,
                email: trimmedEmail,
                guardianContact: trimmedGuardianContact,
                numberOfPeople: max(1, numberOfPeople),
                notes: trimmedNotes,
                preferredStore: (trimmedPreferredStore?.isEmpty == true) ? nil : trimmedPreferredStore
            ),
            at: 0
        )
        dataService.addCareProfile(profiles[0])
        return true
    }

    func validateProfileName(_ rawName: String, excludingProfileId: UUID? = nil) -> CreateProfileNameError? {
        let trimmed = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .empty }
        if trimmed.count < 2 { return .tooShort }
        if profileNameExists(trimmed, excludingProfileId: excludingProfileId) { return .duplicate }
        return nil
    }

    func validatePhone(_ rawPhone: String) -> ContactFieldError? {
        let trimmed = rawPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .empty }
        let digitsCount = trimmed.filter(\.isNumber).count
        return digitsCount >= 6 ? nil : .invalid
    }

    func validateEmail(_ rawEmail: String) -> ContactFieldError? {
        let trimmed = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .empty }
        return (trimmed.contains("@") && trimmed.contains(".")) ? nil : .invalid
    }

    func validateGuardianContact(_ rawGuardianContact: String) -> ContactFieldError? {
        let trimmed = rawGuardianContact.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? .empty : nil
    }

    private func profileNameExists(_ rawName: String, excludingProfileId: UUID? = nil) -> Bool {
        let normalized = normalize(rawName)
        return profiles.contains { profile in
            if let excludeId = excludingProfileId, profile.id == excludeId {
                return false
            }
            return normalize(profile.name) == normalized
        }
    }

    private func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    func deleteProfile(id: UUID) {
        profiles.removeAll { $0.id == id }
        dataService.deleteCareProfile(id: id)
    }

    func updateProfile(_ updated: CareProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == updated.id }) else { return }
        profiles[index] = updated
        dataService.updateCareProfile(updated)
    }
}

