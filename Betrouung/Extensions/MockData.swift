import Foundation

enum MockData {
    static let profiles: [CareProfile] = [
        CareProfile(
            name: "Milica J.",
            address: "Bulevar oslobođenja 12, Novi Sad",
            numberOfPeople: 1,
            notes: "Bez laktoze",
            preferredStore: "Lidl"
        ),
        CareProfile(
            name: "Goran P.",
            address: "Kralja Petra 45, Beograd",
            numberOfPeople: 2,
            notes: "Preferira brendove bez šećera",
            preferredStore: "Maxi"
        ),
    ]

    static let supermarkets: [Store] = [
        Store(name: "Lidl", distance: 1.3, isOpen: true),
        Store(name: "Idea", distance: 2.8, isOpen: false),
        Store(name: "Tempo", distance: 4.2, isOpen: true),
    ]

    static func makeLocalDataServiceForPreviews() -> LocalDataService {
        let store = LocalDataService()
        let profile = profiles[0]
        let list = store.createList(profileId: profile.id)

        store.addItem(listId: list.id, name: "Mleko bez laktoze", category: .Lebensmittel)
        store.addItem(listId: list.id, name: "Pirinač", category: .Lebensmittel)
        store.addItem(listId: list.id, name: "Papirni ubrusi", category: .Haushalt)
        store.addItem(listId: list.id, name: "Šampon", category: .Hygiene)

        // Primer: obeležimo jednu stavku kao “gotovu”
        if let milk = store.lists.first(where: { $0.id == list.id })?.items.first(where: { $0.name.contains("Mleko") }) {
            store.toggleItem(listId: list.id, itemId: milk.id)
        }

        return store
    }
}

