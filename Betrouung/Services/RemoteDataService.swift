import Foundation

@MainActor
final class RemoteDataService: DataService {
    // Placeholder za buduću Supabase implementaciju.
    // Trenutno vraća prazne/no-op rezultate dok backend ne bude povezan.

    func fetchCareProfiles() -> [CareProfile] { [] }
    func addCareProfile(_ profile: CareProfile) {}
    func updateCareProfile(_ profile: CareProfile) {}
    func deleteCareProfile(id: UUID) {}

    func lists(for profileId: UUID) -> [ShoppingList] { [] }
    func createList(profileId: UUID) -> ShoppingList { ShoppingList(profileId: profileId) }
    func latestList(for profileId: UUID) -> ShoppingList? { nil }
    func ensureList(for profileId: UUID) -> ShoppingList { ShoppingList(profileId: profileId) }
    func toggleItem(listId: UUID, itemId: UUID) {}
    func addItem(listId: UUID, name: String, category: ShoppingItemCategory) {}
    func deleteItem(listId: UUID, itemId: UUID) {}

    func allCalendarEntries() -> [CalendarEntry] { [] }
    func calendarEntries(on date: Date) -> [CalendarEntry] { [] }
    func calendarEntries(for profileId: UUID) -> [CalendarEntry] { [] }
    func addCalendarEntry(_ entry: CalendarEntry) {}
    func updateCalendarEntry(_ entry: CalendarEntry) {}
    func deleteCalendarEntry(id: UUID) {}
    func toggleCalendarEntryCompleted(id: UUID) {}
}

