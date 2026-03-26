import Combine
import Foundation

@MainActor
final class CareProfileViewModel: ObservableObject {
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
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        profiles.insert(
            CareProfile(
                name: trimmed,
                address: "",
                numberOfPeople: 1,
                notes: "",
                preferredStore: nil
            ),
            at: 0
        )
        dataService.addCareProfile(profiles[0])
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

