import Foundation

struct Store: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var distance: Double
    var isOpen: Bool
    var latitude: Double?
    var longitude: Double?

    init(
        id: UUID = UUID(),
        name: String,
        distance: Double,
        isOpen: Bool,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.isOpen = isOpen
        self.latitude = latitude
        self.longitude = longitude
    }
}

