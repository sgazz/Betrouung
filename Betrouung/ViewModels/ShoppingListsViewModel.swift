import Foundation

@MainActor
final class ShoppingListViewModel: ObservableObject {
    @Published private(set) var items: [ShoppingItem] = []
    @Published private(set) var groupedItems: [ShoppingItemCategory: [ShoppingItem]] = [:]
    @Published private(set) var suggestedItems: [String] = []
    
    private let profileId: UUID
    private let dataService: any DataService
    private var activeListId: UUID?
    private var itemFrequency: [String: Int] = [:]
    private let suggestionThreshold = 2
    private var hasSeededFrequency = false

    init(profileId: UUID, dataService: any DataService) {
        self.profileId = profileId
        self.dataService = dataService
        refresh()
    }

    func refresh() {
        let list = dataService.ensureList(for: profileId)
        activeListId = list.id
        items = list.items
        groupedItems = Dictionary(grouping: items, by: \.category)
        if !hasSeededFrequency {
            rebuildFrequencyFromCurrentItems()
            hasSeededFrequency = true
        }
        updateSuggestions()
    }

    func createListIfNeeded() {
        _ = dataService.ensureList(for: profileId)
        refresh()
    }

    func addItem(name: String, category: ShoppingItemCategory) {
        guard let listId = activeListId else { return }
        let normalized = normalize(name)
        guard !normalized.isEmpty else { return }

        itemFrequency[normalized, default: 0] += 1
        dataService.addItem(listId: listId, name: name, category: category)
        updateSuggestions()
        refresh()
    }

    func toggleIsChecked(itemId: UUID) {
        guard let listId = activeListId else { return }
        dataService.toggleItem(listId: listId, itemId: itemId)
        refresh()
    }

    func deleteItem(itemId: UUID) {
        guard let listId = activeListId else { return }
        dataService.deleteItem(listId: listId, itemId: itemId)
        refresh()
    }

    func getSuggestedItems() -> [String] {
        suggestedItems
    }

    private func rebuildFrequencyFromCurrentItems() {
        for item in items {
            let normalized = normalize(item.name)
            guard !normalized.isEmpty else { continue }
            itemFrequency[normalized, default: 0] += 1
        }
    }

    private func updateSuggestions() {
        suggestedItems = itemFrequency
            .filter { $0.value >= suggestionThreshold }
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .map(\.key)
            .prefix(8)
            .map { $0 }
    }

    private func normalize(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

