import Combine
import Foundation

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date() {
        didSet { refresh() }
    }
    @Published var selectedProfileId: UUID? {
        didSet { refresh() }
    }
    @Published private(set) var entriesForSelectedDate: [CalendarEntry] = []
    @Published private(set) var entriesForVisibleRange: [CalendarEntry] = []
    @Published private(set) var profiles: [CareProfile] = []

    private let dataService: any DataService

    init(dataService: any DataService) {
        self.dataService = dataService
        refresh()
    }

    func refresh() {
        profiles = dataService.fetchCareProfiles()
        let dayEntries = dataService.calendarEntries(on: selectedDate)
        entriesForSelectedDate = filterByProfile(dayEntries)

        let all = dataService.allCalendarEntries()
        entriesForVisibleRange = filterByProfile(all)
    }

    func addShoppingEvent(
        title: String,
        notes: String,
        scheduledAt: Date,
        profileId: UUID?
    ) {
        addEntry(
            title: title,
            notes: notes,
            scheduledAt: scheduledAt,
            kind: .shopping,
            profileId: profileId
        )
    }

    func addCareReminder(
        title: String,
        notes: String,
        scheduledAt: Date,
        profileId: UUID?
    ) {
        addEntry(
            title: title,
            notes: notes,
            scheduledAt: scheduledAt,
            kind: .careReminder,
            profileId: profileId
        )
    }

    func update(_ entry: CalendarEntry) {
        dataService.updateCalendarEntry(entry)
        refresh()
    }

    func delete(id: UUID) {
        dataService.deleteCalendarEntry(id: id)
        refresh()
    }

    func toggleCompleted(id: UUID) {
        dataService.toggleCalendarEntryCompleted(id: id)
        refresh()
    }

    func entries(for date: Date) -> [CalendarEntry] {
        filterByProfile(dataService.calendarEntries(on: date))
    }

    private func addEntry(
        title: String,
        notes: String,
        scheduledAt: Date,
        kind: CalendarEntryKind,
        profileId: UUID?
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        dataService.addCalendarEntry(
            CalendarEntry(
                profileId: profileId,
                title: trimmed,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                scheduledAt: scheduledAt,
                kind: kind
            )
        )
        refresh()
    }

    private func filterByProfile(_ entries: [CalendarEntry]) -> [CalendarEntry] {
        guard let selectedProfileId else {
            return entries.sorted { $0.scheduledAt < $1.scheduledAt }
        }
        return entries
            .filter { $0.profileId == selectedProfileId }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }
}
