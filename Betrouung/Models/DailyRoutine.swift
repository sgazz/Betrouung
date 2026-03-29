import Foundation

struct RoutineStep: Identifiable, Hashable, Codable {
    var id: UUID
    var title: String
    var sortOrder: Int
    var hour: Int
    var minute: Int

    init(
        id: UUID = UUID(),
        title: String,
        sortOrder: Int,
        hour: Int,
        minute: Int
    ) {
        self.id = id
        self.title = title
        self.sortOrder = sortOrder
        self.hour = hour
        self.minute = minute
    }
}

struct DailyRoutineTemplate: Identifiable, Hashable, Codable {
    var id: UUID
    var profileId: UUID
    var steps: [RoutineStep]
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        profileId: UUID,
        steps: [RoutineStep] = [],
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.profileId = profileId
        self.steps = steps
        self.updatedAt = updatedAt
    }
}

struct RoutineDayCompletion: Identifiable, Hashable, Codable {
    var id: UUID
    var profileId: UUID
    /// `Calendar.current.startOfDay` u lokalnoj vremenskoj zoni
    var day: Date
    var completedStepIds: Set<UUID>

    init(
        id: UUID = UUID(),
        profileId: UUID,
        day: Date,
        completedStepIds: Set<UUID> = []
    ) {
        self.id = id
        self.profileId = profileId
        self.day = day
        self.completedStepIds = completedStepIds
    }
}
