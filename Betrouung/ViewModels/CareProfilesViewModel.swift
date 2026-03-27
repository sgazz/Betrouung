import Combine
import Foundation

@MainActor
final class CareProfileViewModel: ObservableObject {
    enum CreateProfileNameError {
        case empty
        case tooShort
        case duplicate
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
            numberOfPeople: 1,
            notes: "",
            preferredStore: nil
        )
    }

    @discardableResult
    func addProfile(
        name: String,
        address: String,
        numberOfPeople: Int,
        notes: String,
        preferredStore: String?
    ) -> Bool {
        guard validateProfileName(name) == nil else { return false }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPreferredStore = preferredStore?.trimmingCharacters(in: .whitespacesAndNewlines)
        profiles.insert(
            CareProfile(
                name: trimmed,
                address: trimmedAddress,
                numberOfPeople: max(1, numberOfPeople),
                notes: trimmedNotes,
                preferredStore: (trimmedPreferredStore?.isEmpty == true) ? nil : trimmedPreferredStore
            ),
            at: 0
        )
        dataService.addCareProfile(profiles[0])
        return true
    }

    func validateProfileName(_ rawName: String) -> CreateProfileNameError? {
        let trimmed = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .empty }
        if trimmed.count < 2 { return .tooShort }
        if profileNameExists(trimmed) { return .duplicate }
        return nil
    }

    private func profileNameExists(_ rawName: String) -> Bool {
        let normalized = normalize(rawName)
        return profiles.contains { normalize($0.name) == normalized }
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

