import Combine
import Foundation

@MainActor
final class LocalDataService: DataService, ObservableObject {
    @Published private(set) var profiles: [CareProfile]
    @Published private(set) var lists: [ShoppingList]

    init(
        profiles: [CareProfile],
        lists: [ShoppingList] = []
    ) {
        self.profiles = profiles
        self.lists = lists
    }

    convenience init() {
        self.init(profiles: MockData.profiles, lists: [])
    }

    // MARK: - Care profiles
    func fetchCareProfiles() -> [CareProfile] {
        profiles
    }

    func addCareProfile(_ profile: CareProfile) {
        profiles.insert(profile, at: 0)
    }

    func updateCareProfile(_ profile: CareProfile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index] = profile
    }

    func deleteCareProfile(id: UUID) {
        profiles.removeAll { $0.id == id }
        lists.removeAll { $0.profileId == id }
    }

    // MARK: - Shopping lists and items
    func lists(for profileId: UUID) -> [ShoppingList] {
        lists
            .filter { $0.profileId == profileId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func createList(profileId: UUID) -> ShoppingList {
        let list = ShoppingList(profileId: profileId)
        lists.insert(list, at: 0)
        return list
    }

    func latestList(for profileId: UUID) -> ShoppingList? {
        lists(for: profileId).first
    }

    func ensureList(for profileId: UUID) -> ShoppingList {
        if let list = latestList(for: profileId) {
            return list
        }
        return createList(profileId: profileId)
    }

    func toggleItem(listId: UUID, itemId: UUID) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }) else { return }
        guard let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == itemId }) else { return }
        lists[listIndex].items[itemIndex].isChecked.toggle()
    }

    func addItem(listId: UUID, name: String, category: ShoppingItemCategory) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else { return }
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }) else { return }

        lists[listIndex].items.append(
            ShoppingItem(name: n, category: category, isChecked: false, createdAt: Date())
        )
    }

    func deleteItem(listId: UUID, itemId: UUID) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }) else { return }
        lists[listIndex].items.removeAll { $0.id == itemId }
    }
}

