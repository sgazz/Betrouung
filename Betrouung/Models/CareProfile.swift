import Foundation

struct CareProfile: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var address: String
    var numberOfPeople: Int
    var notes: String
    var preferredStore: String?

    init(
        id: UUID = UUID(),
        name: String,
        address: String = "",
        numberOfPeople: Int = 1,
        notes: String = "",
        preferredStore: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.numberOfPeople = numberOfPeople
        self.notes = notes
        self.preferredStore = preferredStore
    }
}

