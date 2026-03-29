//
//  BetrouungTests.swift
//  BetrouungTests
//

import Testing
@testable import Betrouung

@MainActor
struct CareProfileViewModelValidationTests {

    private func makeViewModel() -> CareProfileViewModel {
        CareProfileViewModel(dataService: LocalDataService())
    }

    @Test func validateProfileName_empty_returnsEmpty() {
        let vm = makeViewModel()
        #expect(vm.validateProfileName("") == .empty)
        #expect(vm.validateProfileName("   ") == .empty)
    }

    @Test func validateProfileName_tooShort_returnsTooShort() {
        let vm = makeViewModel()
        #expect(vm.validateProfileName("a") == .tooShort)
    }

    @Test func validateProfileName_sameName_excludingSelf_returnsNil() {
        let vm = makeViewModel()
        guard let profile = vm.profiles.first else {
            Issue.record("Expected at least one mock profile.")
            return
        }
        #expect(vm.validateProfileName(profile.name, excludingProfileId: profile.id) == nil)
    }

    @Test func validateProfileName_otherExistingName_returnsDuplicate() {
        let vm = makeViewModel()
        guard vm.profiles.count >= 2 else {
            Issue.record("Expected at least two mock profiles.")
            return
        }
        let first = vm.profiles[0]
        let second = vm.profiles[1]
        #expect(vm.validateProfileName(second.name, excludingProfileId: first.id) == .duplicate)
    }

    @Test func validatePhone_empty_returnsEmpty() {
        let vm = makeViewModel()
        #expect(vm.validatePhone("") == .empty)
    }

    @Test func validatePhone_tooFewDigits_returnsInvalid() {
        let vm = makeViewModel()
        #expect(vm.validatePhone("12345") == .invalid)
    }

    @Test func validatePhone_enoughDigits_returnsNil() {
        let vm = makeViewModel()
        #expect(vm.validatePhone("+381 64 123 4567") == nil)
    }

    @Test func validateEmail_empty_returnsEmpty() {
        let vm = makeViewModel()
        #expect(vm.validateEmail("") == .empty)
    }

    @Test func validateEmail_invalid_returnsInvalid() {
        let vm = makeViewModel()
        #expect(vm.validateEmail("not-an-email") == .invalid)
    }

    @Test func validateEmail_minimalValid_returnsNil() {
        let vm = makeViewModel()
        #expect(vm.validateEmail("a@b.co") == nil)
    }

    @Test func validateGuardianContact_empty_returnsEmpty() {
        let vm = makeViewModel()
        #expect(vm.validateGuardianContact("") == .empty)
        #expect(vm.validateGuardianContact("  ") == .empty)
    }

    @Test func validateGuardianContact_nonEmpty_returnsNil() {
        let vm = makeViewModel()
        #expect(vm.validateGuardianContact("Ana") == nil)
    }
}
