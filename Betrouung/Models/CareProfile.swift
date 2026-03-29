import Foundation

struct CareProfile: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var address: String
    var phone: String
    var email: String
    var guardianContact: String
    var numberOfPeople: Int
    var notes: String
    var preferredStore: String?

    init(
        id: UUID = UUID(),
        name: String,
        address: String = "",
        phone: String = "",
        email: String = "",
        guardianContact: String = "",
        numberOfPeople: Int = 1,
        notes: String = "",
        preferredStore: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.email = email
        self.guardianContact = guardianContact
        self.numberOfPeople = numberOfPeople
        self.notes = notes
        self.preferredStore = preferredStore
    }
}

