//
//  DailyRoutineViewModelTests.swift
//  BetrouungTests
//

import Foundation
import Testing
@testable import Betrouung

@MainActor
struct DailyRoutineViewModelTests {

    @Test func toggleRoutineStepCompleted_togglesAndRemovesEmpty() {
        let svc = LocalDataService(profiles: [], lists: [], calendarEntries: [])
        let profileId = UUID()
        let step = RoutineStep(title: "Breakfast", sortOrder: 0, hour: 7, minute: 30)
        svc.saveDailyRoutineTemplate(
            DailyRoutineTemplate(profileId: profileId, steps: [step])
        )
        let day = Date()
        #expect(svc.routineCompletedStepIds(for: profileId, day: day).isEmpty)

        svc.toggleRoutineStepCompleted(profileId: profileId, stepId: step.id, day: day)
        #expect(svc.routineCompletedStepIds(for: profileId, day: day) == Set([step.id]))

        svc.toggleRoutineStepCompleted(profileId: profileId, stepId: step.id, day: day)
        #expect(svc.routineCompletedStepIds(for: profileId, day: day).isEmpty)
    }

    @Test func viewModel_sortsStepsByTime() {
        let svc = LocalDataService(profiles: [], lists: [], calendarEntries: [])
        let profileId = UUID()
        let late = RoutineStep(title: "Late", sortOrder: 0, hour: 12, minute: 0)
        let early = RoutineStep(title: "Early", sortOrder: 1, hour: 6, minute: 0)
        svc.saveDailyRoutineTemplate(
            DailyRoutineTemplate(profileId: profileId, steps: [late, early])
        )
        let vm = DailyRoutineViewModel(profileId: profileId, dataService: svc)
        #expect(vm.sortedSteps.map(\RoutineStep.title) == ["Early", "Late"])
    }

    @Test func deleteCareProfile_removesRoutineData() {
        let pid = UUID()
        let profile = CareProfile(id: pid, name: "Test")
        let svc = LocalDataService(profiles: [profile], lists: [], calendarEntries: [])
        svc.saveDailyRoutineTemplate(
            DailyRoutineTemplate(
                profileId: pid,
                steps: [RoutineStep(title: "A", sortOrder: 0, hour: 8, minute: 0)]
            )
        )
        svc.toggleRoutineStepCompleted(
            profileId: pid,
            stepId: svc.dailyRoutineTemplate(for: pid)!.steps[0].id,
            day: Date()
        )
        #expect(svc.dailyRoutineTemplate(for: pid) != nil)
        svc.deleteCareProfile(id: pid)
        #expect(svc.dailyRoutineTemplate(for: pid) == nil)
    }
}
