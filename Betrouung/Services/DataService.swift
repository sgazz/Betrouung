import Foundation

@MainActor
protocol DataService: AnyObject {
    // Care profiles
    func fetchCareProfiles() -> [CareProfile]
    func addCareProfile(_ profile: CareProfile)
    func updateCareProfile(_ profile: CareProfile)
    func deleteCareProfile(id: UUID)

    // Shopping lists and items
    func lists(for profileId: UUID) -> [ShoppingList]
    func createList(profileId: UUID) -> ShoppingList
    func latestList(for profileId: UUID) -> ShoppingList?
    func ensureList(for profileId: UUID) -> ShoppingList
    func toggleItem(listId: UUID, itemId: UUID)
    func addItem(listId: UUID, name: String, category: ShoppingItemCategory)
    func deleteItem(listId: UUID, itemId: UUID)

    // Calendar entries
    func allCalendarEntries() -> [CalendarEntry]
    func calendarEntries(on date: Date) -> [CalendarEntry]
    func calendarEntries(for profileId: UUID) -> [CalendarEntry]
    func addCalendarEntry(_ entry: CalendarEntry)
    func updateCalendarEntry(_ entry: CalendarEntry)
    func deleteCalendarEntry(id: UUID)
    func toggleCalendarEntryCompleted(id: UUID)

    // Daily routine (Care) — šablon po profilu + štikliranje po danu
    func dailyRoutineTemplate(for profileId: UUID) -> DailyRoutineTemplate?
    func saveDailyRoutineTemplate(_ template: DailyRoutineTemplate)
    func routineCompletedStepIds(for profileId: UUID, day: Date) -> Set<UUID>
    func toggleRoutineStepCompleted(profileId: UUID, stepId: UUID, day: Date)
}

