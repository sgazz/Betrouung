import Combine
import Foundation
import SwiftUI

@MainActor
final class DailyRoutineViewModel: ObservableObject {
    private let dataService: any DataService
    let profileId: UUID

    @Published var selectedDay: Date
    @Published private(set) var sortedSteps: [RoutineStep] = []
    @Published private(set) var completedStepIds: Set<UUID> = []
    @Published var isEditingTemplate = false
    @Published var editingSteps: [RoutineStep] = []

    init(profileId: UUID, dataService: any DataService, initialDay: Date = Date()) {
        self.profileId = profileId
        self.dataService = dataService
        self.selectedDay = Calendar.current.startOfDay(for: initialDay)
        refresh()
    }

    func refresh() {
        let template = dataService.dailyRoutineTemplate(for: profileId)
        let steps = template?.steps ?? []
        sortedSteps = Self.sortSteps(steps)
        completedStepIds = dataService.routineCompletedStepIds(for: profileId, day: selectedDay)
        if isEditingTemplate {
            editingSteps = sortedSteps
        }
    }

    private static func sortSteps(_ steps: [RoutineStep]) -> [RoutineStep] {
        steps.sorted { lhs, rhs in
            if lhs.hour != rhs.hour { return lhs.hour < rhs.hour }
            if lhs.minute != rhs.minute { return lhs.minute < rhs.minute }
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    func shiftSelectedDay(by days: Int) {
        selectedDay =
            Calendar.current.date(byAdding: .day, value: days, to: selectedDay)
            ?? selectedDay
        refresh()
    }

    func goToToday() {
        selectedDay = Calendar.current.startOfDay(for: Date())
        refresh()
    }

    func toggleCompleted(stepId: UUID) {
        dataService.toggleRoutineStepCompleted(profileId: profileId, stepId: stepId, day: selectedDay)
        refresh()
    }

    func beginEditing() {
        editingSteps = sortedSteps
        isEditingTemplate = true
    }

    func cancelEditing() {
        isEditingTemplate = false
        editingSteps = []
        refresh()
    }

    func saveTemplateEdits() {
        let existing = dataService.dailyRoutineTemplate(for: profileId)
        let normalized = editingSteps.enumerated().map { index, step -> RoutineStep in
            var s = step
            s.sortOrder = index
            return s
        }
        let template = DailyRoutineTemplate(
            id: existing?.id ?? UUID(),
            profileId: profileId,
            steps: normalized,
            updatedAt: Date()
        )
        dataService.saveDailyRoutineTemplate(template)
        isEditingTemplate = false
        editingSteps = []
        refresh()
    }

    func addEditingStep() {
        let nextOrder = editingSteps.map(\.sortOrder).max().map { $0 + 1 } ?? 0
        let cal = Calendar.current
        let hour = cal.component(.hour, from: Date())
        let minute = cal.component(.minute, from: Date())
        editingSteps.append(
            RoutineStep(title: "", sortOrder: nextOrder, hour: hour, minute: minute)
        )
    }

    func deleteEditingSteps(at offsets: IndexSet) {
        editingSteps.remove(atOffsets: offsets)
    }

    func moveEditingSteps(from: IndexSet, to: Int) {
        editingSteps.move(fromOffsets: from, toOffset: to)
    }

    func updateEditingStepTitle(id: UUID, title: String) {
        guard let i = editingSteps.firstIndex(where: { $0.id == id }) else { return }
        var copy = editingSteps
        copy[i].title = title
        editingSteps = copy
    }

    func dateForStep(_ step: RoutineStep) -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: selectedDay)
        c.hour = step.hour
        c.minute = step.minute
        c.second = 0
        return Calendar.current.date(from: c) ?? selectedDay
    }

    func updateEditingStepTime(id: UUID, date: Date) {
        guard let i = editingSteps.firstIndex(where: { $0.id == id }) else { return }
        let cal = Calendar.current
        var copy = editingSteps
        copy[i].hour = cal.component(.hour, from: date)
        copy[i].minute = cal.component(.minute, from: date)
        editingSteps = copy
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDay)
    }
}
