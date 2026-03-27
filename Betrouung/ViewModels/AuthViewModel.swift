import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    private enum AuthStorageKeys {
        static let rememberMe = "auth.rememberMe"
        static let persistedSession = "auth.persistedSession"
    }

    enum AuthMode: String, CaseIterable, Identifiable {
        case login = "Prijava"
        case createAccount = "Kreiraj nalog"

        var id: String { rawValue }
    }

    @Published var mode: AuthMode = .login
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var rememberMe: Bool {
        didSet {
            UserDefaults.standard.set(rememberMe, forKey: AuthStorageKeys.rememberMe)
            if !rememberMe {
                UserDefaults.standard.set(false, forKey: AuthStorageKeys.persistedSession)
            }
        }
    }
    @Published private(set) var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    private var mockUsers: [String: String] = [
        "demo@betrouung.app": "123456"
    ]

    init() {
        let savedRememberMe = UserDefaults.standard.bool(forKey: AuthStorageKeys.rememberMe)
        self.rememberMe = savedRememberMe
        if savedRememberMe {
            self.isAuthenticated = UserDefaults.standard.bool(forKey: AuthStorageKeys.persistedSession)
        } else {
            self.isAuthenticated = false
        }
    }

    var emailValidationMessage: String? {
        let value = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return "Email je obavezan." }
        guard value.contains("@"), value.contains(".") else { return "Unesite ispravan email." }
        return nil
    }

    var passwordValidationMessage: String? {
        let value = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return "Lozinka je obavezna." }
        guard value.count >= 6 else { return "Lozinka mora imati najmanje 6 karaktera." }
        return nil
    }

    var fullNameValidationMessage: String? {
        let value = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Ime i prezime je obavezno." : nil
    }

    var confirmPasswordValidationMessage: String? {
        let value = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return "Potvrda lozinke je obavezna." }
        guard value == currentPassword else { return "Lozinke se ne poklapaju." }
        return nil
    }

    var canSubmitLogin: Bool {
        emailValidationMessage == nil && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canSubmitCreateAccount: Bool {
        fullNameValidationMessage == nil &&
        emailValidationMessage == nil &&
        passwordValidationMessage == nil &&
        confirmPasswordValidationMessage == nil
    }

    var liveValidationMessage: String? {
        switch mode {
        case .login:
            return emailValidationMessage ?? (password.isEmpty ? nil : passwordValidationMessage)
        case .createAccount:
            return fullNameValidationMessage ??
                emailValidationMessage ??
                passwordValidationMessage ??
                (confirmPassword.isEmpty ? nil : confirmPasswordValidationMessage)
        }
    }

    func login() {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        infoMessage = nil

        guard !normalizedEmail.isEmpty, !normalizedPassword.isEmpty else {
            errorMessage = "Unesite email i lozinku."
            return
        }

        if mockUsers[normalizedEmail] == normalizedPassword {
            errorMessage = nil
            isAuthenticated = true
            persistSessionIfNeeded()
        } else {
            errorMessage = "Pogrešan email ili lozinka."
        }
    }

    func createAccount() {
        let normalizedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedConfirmation = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        infoMessage = nil

        guard !normalizedName.isEmpty else {
            errorMessage = "Unesite ime i prezime."
            return
        }
        guard !normalizedEmail.isEmpty, !normalizedPassword.isEmpty else {
            errorMessage = "Unesite email i lozinku."
            return
        }
        guard normalizedPassword.count >= 6 else {
            errorMessage = "Lozinka mora imati najmanje 6 karaktera."
            return
        }
        guard normalizedPassword == normalizedConfirmation else {
            errorMessage = "Lozinke se ne poklapaju."
            return
        }
        guard mockUsers[normalizedEmail] == nil else {
            errorMessage = "Nalog sa tim email-om već postoji."
            return
        }

        mockUsers[normalizedEmail] = normalizedPassword
        errorMessage = nil
        isAuthenticated = true
        persistSessionIfNeeded()
    }

    func forgotPassword(for rawEmail: String) {
        let normalizedEmail = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        errorMessage = nil
        infoMessage = nil

        guard !normalizedEmail.isEmpty else {
            errorMessage = "Unesite email za reset lozinke."
            return
        }
        guard normalizedEmail.contains("@"), normalizedEmail.contains(".") else {
            errorMessage = "Unesite ispravan email."
            return
        }
        guard mockUsers[normalizedEmail] != nil else {
            errorMessage = "Nalog sa tim email-om ne postoji."
            return
        }

        infoMessage = "Mock link za reset lozinke je poslat na \(normalizedEmail)."
    }

    func setMode(_ mode: AuthMode) {
        self.mode = mode
        errorMessage = nil
        infoMessage = nil
        password = ""
        confirmPassword = ""
    }

    func clearTransientMessages() {
        errorMessage = nil
        infoMessage = nil
    }

    func logout() {
        isAuthenticated = false
        password = ""
        confirmPassword = ""
        UserDefaults.standard.set(false, forKey: AuthStorageKeys.persistedSession)
    }

    private func persistSessionIfNeeded() {
        UserDefaults.standard.set(rememberMe && isAuthenticated, forKey: AuthStorageKeys.persistedSession)
    }
}
