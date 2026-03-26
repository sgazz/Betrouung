import Foundation

struct ShoppingList: Identifiable, Hashable, Codable {
    var id: UUID
    var profileId: UUID
    var items: [ShoppingItem]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        profileId: UUID,
        items: [ShoppingItem] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.profileId = profileId
        self.items = items
        self.createdAt = createdAt
    }
}

