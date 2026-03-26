import Foundation

enum ShoppingItemCategory: String, Codable, CaseIterable {
    case Lebensmittel
    case Hygiene
    case Haushalt
}

struct ShoppingItem: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var category: ShoppingItemCategory
    var isChecked: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: ShoppingItemCategory = .Lebensmittel,
        isChecked: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.isChecked = isChecked
        self.createdAt = createdAt
    }
}

