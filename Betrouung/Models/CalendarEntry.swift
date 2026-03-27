import Foundation

enum CalendarEntryKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case shopping
    case careReminder

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shopping:
            return "Shopping"
        case .careReminder:
            return "Care Reminder"
        }
    }
}

struct CalendarEntry: Identifiable, Hashable, Codable {
    var id: UUID
    var profileId: UUID?
    var listId: UUID?
    var title: String
    var notes: String
    var scheduledAt: Date
    var kind: CalendarEntryKind
    var isCompleted: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        profileId: UUID? = nil,
        listId: UUID? = nil,
        title: String,
        notes: String = "",
        scheduledAt: Date,
        kind: CalendarEntryKind,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.profileId = profileId
        self.listId = listId
        self.title = title
        self.notes = notes
        self.scheduledAt = scheduledAt
        self.kind = kind
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
