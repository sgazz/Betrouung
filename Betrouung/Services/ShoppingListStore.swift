import Combine
import Foundation

@MainActor
final class LocalDataService: DataService, ObservableObject {
    @Published private(set) var profiles: [CareProfile]
    @Published private(set) var lists: [ShoppingList]
    @Published private(set) var calendarEntriesStore: [CalendarEntry]
    @Published private(set) var routineTemplates: [DailyRoutineTemplate]
    @Published private(set) var routineCompletions: [RoutineDayCompletion]

    init(
        profiles: [CareProfile],
        lists: [ShoppingList] = [],
        calendarEntries: [CalendarEntry] = [],
        routineTemplates: [DailyRoutineTemplate] = [],
        routineCompletions: [RoutineDayCompletion] = []
    ) {
        self.profiles = profiles
        self.lists = lists
        self.calendarEntriesStore = calendarEntries
        self.routineTemplates = routineTemplates
        self.routineCompletions = routineCompletions
    }

    convenience init() {
        self.init(profiles: MockData.profiles, lists: [], calendarEntries: MockData.calendarEntries)
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
        routineTemplates = routineTemplates.filter { $0.profileId != id }
        routineCompletions = routineCompletions.filter { $0.profileId != id }
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

    // MARK: - Calendar entries
    func allCalendarEntries() -> [CalendarEntry] {
        calendarEntriesStore.sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func calendarEntries(on date: Date) -> [CalendarEntry] {
        let calendar = Calendar.current
        return calendarEntriesStore
            .filter { calendar.isDate($0.scheduledAt, inSameDayAs: date) }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func calendarEntries(for profileId: UUID) -> [CalendarEntry] {
        calendarEntriesStore
            .filter { $0.profileId == profileId }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func addCalendarEntry(_ entry: CalendarEntry) {
        calendarEntriesStore.append(entry)
    }

    func updateCalendarEntry(_ entry: CalendarEntry) {
        guard let index = calendarEntriesStore.firstIndex(where: { $0.id == entry.id }) else { return }
        calendarEntriesStore[index] = entry
    }

    func deleteCalendarEntry(id: UUID) {
        calendarEntriesStore.removeAll { $0.id == id }
    }

    func toggleCalendarEntryCompleted(id: UUID) {
        guard let index = calendarEntriesStore.firstIndex(where: { $0.id == id }) else { return }
        calendarEntriesStore[index].isCompleted.toggle()
    }

    // MARK: - Daily routine

    func dailyRoutineTemplate(for profileId: UUID) -> DailyRoutineTemplate? {
        routineTemplates.first { $0.profileId == profileId }
    }

    func saveDailyRoutineTemplate(_ template: DailyRoutineTemplate) {
        var next = routineTemplates
        if let index = next.firstIndex(where: { $0.profileId == template.profileId }) {
            next[index] = template
        } else {
            next.append(template)
        }
        routineTemplates = next
    }

    func routineCompletedStepIds(for profileId: UUID, day: Date) -> Set<UUID> {
        let start = Calendar.current.startOfDay(for: day)
        return routineCompletions.first {
            $0.profileId == profileId && Calendar.current.isDate($0.day, inSameDayAs: start)
        }?.completedStepIds ?? []
    }

    func toggleRoutineStepCompleted(profileId: UUID, stepId: UUID, day: Date) {
        let start = Calendar.current.startOfDay(for: day)
        var comps = routineCompletions
        if let index = comps.firstIndex(where: {
            $0.profileId == profileId && Calendar.current.isDate($0.day, inSameDayAs: start)
        }) {
            if comps[index].completedStepIds.contains(stepId) {
                comps[index].completedStepIds.remove(stepId)
            } else {
                comps[index].completedStepIds.insert(stepId)
            }
            if comps[index].completedStepIds.isEmpty {
                comps.remove(at: index)
            }
        } else {
            comps.append(
                RoutineDayCompletion(profileId: profileId, day: start, completedStepIds: [stepId])
            )
        }
        routineCompletions = comps
    }
}

