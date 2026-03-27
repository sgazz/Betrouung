import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedField: LoginField?
    @State private var isShowingForgotPassword = false
    @State private var forgotPasswordEmail = ""
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private enum LoginField: Hashable {
        case fullName
        case email
        case password
        case confirmPassword
    }

    private var loginTitleText: String {
        viewModel.mode == .login
            ? L10n.t("login.sign_in", languageCode: selectedLanguageRaw)
            : L10n.t("login.create_account", languageCode: selectedLanguageRaw)
    }

    private var loginSubtitleText: String {
        viewModel.mode == .login
            ? L10n.t("login.subtitle.sign_in", languageCode: selectedLanguageRaw)
            : L10n.t("login.subtitle.create_account", languageCode: selectedLanguageRaw)
    }

    private var rememberMeText: String {
        L10n.t("login.remember_me", languageCode: selectedLanguageRaw)
    }

    private var forgotPasswordText: String {
        L10n.t("login.forgot_password", languageCode: selectedLanguageRaw)
    }

    private var loginButtonText: String {
        viewModel.mode == .login
            ? L10n.t("login.button.sign_in", languageCode: selectedLanguageRaw)
            : L10n.t("login.button.create_account", languageCode: selectedLanguageRaw)
    }

    private var resetTitleText: String {
        L10n.t("login.reset.title", languageCode: selectedLanguageRaw)
    }

    private var resetHintText: String {
        L10n.t("login.reset.hint", languageCode: selectedLanguageRaw)
    }

    private var resetSendText: String {
        L10n.t("login.reset.send", languageCode: selectedLanguageRaw)
    }

    private var cancelText: String {
        L10n.t("common.cancel", languageCode: selectedLanguageRaw)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 16) {
                Spacer()

                VStack(spacing: 16) {
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 84, height: 84)
                        .shadow(color: AppPalette.orange.opacity(0.15), radius: 10, x: 0, y: 6)

                    Text(loginTitleText)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)

                    Text(loginSubtitleText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Picker("Autentikacija", selection: $viewModel.mode) {
                        ForEach(AuthViewModel.AuthMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.mode) { _, newMode in
                        viewModel.setMode(newMode)
                        focusedField = newMode == .createAccount ? .fullName : .email
                    }

                    VStack(spacing: 12) {
                        if viewModel.mode == .createAccount {
                            HStack(spacing: 8) {
                                TextField("Ime i prezime", text: $viewModel.fullName)
                                    .textInputAutocapitalization(.words)
                                    .focused($focusedField, equals: .fullName)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .email }
                                    .appInputFieldStyle(isFocused: focusedField == .fullName)
                                VoiceInputButton(text: $viewModel.fullName)
                            }
                        }

                        HStack(spacing: 8) {
                            TextField("Email", text: $viewModel.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .password }
                                .appInputFieldStyle(isFocused: focusedField == .email)
                            VoiceInputButton(text: $viewModel.email)
                        }

                        SecureField("Lozinka", text: $viewModel.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(viewModel.mode == .login ? .go : .next)
                            .onSubmit {
                                if viewModel.mode == .login {
                                    viewModel.login()
                                } else {
                                    focusedField = .confirmPassword
                                }
                            }
                            .appInputFieldStyle(isFocused: focusedField == .password)

                        if viewModel.mode == .createAccount {
                            SecureField("Potvrdite lozinku", text: $viewModel.confirmPassword)
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.go)
                                .onSubmit { viewModel.createAccount() }
                                .appInputFieldStyle(isFocused: focusedField == .confirmPassword)
                        }

                        if viewModel.mode == .login {
                            Toggle(isOn: $viewModel.rememberMe) {
                                Text(rememberMeText)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            .tint(AppPalette.orange)
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.body)
                            .foregroundStyle(AppPalette.red)
                    }
                    if let infoMessage = viewModel.infoMessage {
                        Text(infoMessage)
                            .font(.body)
                            .foregroundStyle(AppPalette.green)
                            .multilineTextAlignment(.center)
                    }
                    if let liveValidationMessage = viewModel.liveValidationMessage,
                       viewModel.errorMessage == nil,
                       viewModel.infoMessage == nil {
                        Text(liveValidationMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        if viewModel.mode == .login {
                            viewModel.login()
                        } else {
                            viewModel.createAccount()
                        }
                    } label: {
                        Text(loginButtonText)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(AppPalette.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PrimaryCTAButtonStyle())
                    .disabled(viewModel.mode == .login ? !viewModel.canSubmitLogin : !viewModel.canSubmitCreateAccount)
                    .opacity((viewModel.mode == .login ? viewModel.canSubmitLogin : viewModel.canSubmitCreateAccount) ? 1 : 0.6)

                    if viewModel.mode == .login {
                        Button(forgotPasswordText) {
                            forgotPasswordEmail = viewModel.email
                            isShowingForgotPassword = true
                        }
                        .font(.body)
                        .foregroundStyle(AppPalette.orange)
                    }
                }
                .padding(20)
                .appGlassCard()
                .padding(.horizontal, 16)

                if viewModel.mode == .login {
                    Text("Demo: demo@betrouung.app / 123456")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }

                Spacer()
            }
            .padding(.vertical, 16)
        }
        .onAppear { focusedField = .email }
        .onChange(of: viewModel.email) { _, _ in viewModel.clearTransientMessages() }
        .onChange(of: viewModel.password) { _, _ in viewModel.clearTransientMessages() }
        .onChange(of: viewModel.confirmPassword) { _, _ in viewModel.clearTransientMessages() }
        .onChange(of: viewModel.fullName) { _, _ in viewModel.clearTransientMessages() }
        .sheet(isPresented: $isShowingForgotPassword) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text(resetHintText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Email", text: $forgotPasswordEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .appInputFieldStyle()
                    VoiceInputButton(text: $forgotPasswordEmail)

                    Button(resetSendText) {
                        viewModel.forgotPassword(for: forgotPasswordEmail)
                        isShowingForgotPassword = false
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(AppPalette.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .buttonStyle(PrimaryCTAButtonStyle())

                    Spacer()
                }
                .padding(16)
                .navigationTitle(resetTitleText)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(cancelText) {
                            isShowingForgotPassword = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
