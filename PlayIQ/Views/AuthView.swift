import SwiftUI

enum AuthMode {
    case login
    case signup
    case forgotPassword
    case resetPassword
}

struct AuthView: View {
    @EnvironmentObject var playerStore: PlayerStore
    @State private var authMode: AuthMode = .login
    @State private var username = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var parentEmail = ""
    @State private var resetCode = ""
    @State private var newPassword = ""
    @State private var resetSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("PLAY")
                        .font(.system(size: 44, weight: .black))
                        .foregroundColor(PlayIQColors.text)
                    Text("IQ")
                        .font(.system(size: 44, weight: .black))
                        .foregroundColor(PlayIQColors.gold)
                }

                Text("Think the game. Play the game.")
                    .font(PlayIQFonts.callout)
                    .foregroundColor(PlayIQColors.textSecondary)
            }
            .padding(.bottom, 48)

            // Tab Picker (login/signup only)
            if authMode == .login || authMode == .signup {
                HStack(spacing: 0) {
                    tabButton(title: "Sign In", isActive: authMode == .login) {
                        withAnimation { authMode = .login }
                        playerStore.errorMessage = nil
                    }
                    tabButton(title: "I'm New", isActive: authMode == .signup) {
                        withAnimation { authMode = .signup }
                        playerStore.errorMessage = nil
                    }
                }
                .background(PlayIQColors.card)
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }

            // Form
            VStack(spacing: 16) {
                switch authMode {
                case .login:
                    loginForm
                case .signup:
                    signupForm
                case .forgotPassword:
                    forgotPasswordForm
                case .resetPassword:
                    resetPasswordForm
                }

                if let error = playerStore.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(PlayIQColors.resultBad)
                        Text(error)
                            .font(PlayIQFonts.caption)
                            .foregroundColor(PlayIQColors.resultBad)
                    }
                }

                if let success = playerStore.successMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(success)
                            .font(PlayIQFonts.caption)
                            .foregroundColor(.green)
                    }
                }

                if resetSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Password reset! Log in with your new password.")
                            .font(PlayIQFonts.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            // Guest option
            Button(action: { playerStore.playAsGuest() }) {
                Text("Play as Guest")
                    .font(PlayIQFonts.callout)
                    .foregroundColor(PlayIQColors.textSecondary)
                    .underline()
            }
            .padding(.bottom, 16)

            // Coach login
            Link(destination: URL(string: "https://app.playiqapp.com/coach")!) {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                    Text("I'm a Coach")
                        .font(PlayIQFonts.callout)
                }
                .foregroundColor(PlayIQColors.textSecondary)
            }
            .padding(.bottom, 40)
        }
        .background(PlayIQColors.background.ignoresSafeArea())
    }

    // MARK: - Login Form

    private var loginForm: some View {
        VStack(spacing: 16) {
            fieldGroup(label: "Username") {
                TextField("", text: $username)
                    .textFieldStyle(.plain)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .padding(14)
                    .background(PlayIQColors.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PlayIQColors.cardBorder, lineWidth: 1))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            fieldGroup(label: "Password") {
                SecureField("", text: $password)
                    .textFieldStyle(.plain)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .padding(14)
                    .background(PlayIQColors.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PlayIQColors.cardBorder, lineWidth: 1))
            }

            actionButton(title: "Let's Play!", enabled: !username.isEmpty && !password.isEmpty) {
                Task {
                    resetSuccess = false
                    await playerStore.login(username: username, password: password)
                }
            }

            Button(action: {
                withAnimation {
                    authMode = .forgotPassword
                    playerStore.errorMessage = nil
                    playerStore.successMessage = nil
                }
            }) {
                Text("Forgot Password?")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.gold.opacity(0.8))
            }
        }
    }

    // MARK: - Signup Form

    private var signupForm: some View {
        VStack(spacing: 16) {
            fieldGroup(label: "What's Your Name?") {
                TextField("", text: $displayName)
                    .textFieldStyle(.plain)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .padding(14)
                    .background(PlayIQColors.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PlayIQColors.cardBorder, lineWidth: 1))
                    .autocorrectionDisabled()
            }

            fieldGroup(label: "Pick a Username") {
                TextField("", text: $username)
                    .textFieldStyle(.plain)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .padding(14)
                    .background(PlayIQColors.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PlayIQColors.cardBorder, lineWidth: 1))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            fieldGroup(label: "Create a Password") {
                SecureField("At least 4 characters", text: $password)
                    .textFieldStyle(.plain)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .padding(14)
                    .background(PlayIQColors.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PlayIQColors.cardBorder, lineWidth: 1))
            }

            fieldGroup(label: "Parent/Guardian Email", optional: "for password resets") {
                TextField("parent@example.com", text: $parentEmail)
                    .textFieldStyle(.plain)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .padding(14)
                    .background(PlayIQColors.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PlayIQColors.cardBorder, lineWidth: 1))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
            }

            actionButton(title: "Create Player", enabled: !username.isEmpty && !displayName.isEmpty && password.count >= 4) {
                Task {
                    await playerStore.signup(username: username, displayName: displayName, password: password, parentEmail: parentEmail)
                }
            }
        }
    }

    // MARK: - Forgot Password Form

    private var forgotPasswordForm: some View {
        VStack(spacing: 16) {
            Text("Enter your username and we'll send a reset code to your parent's email.")
                .font(PlayIQFonts.caption)
                .foregroundColor(PlayIQColors.textSecondary)
                .multilineTextAlignment(.center)

            fieldGroup(label: "Username") {
                TextField("", text: $username)
                    .textFieldStyle(.plain)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .padding(14)
                    .background(PlayIQColors.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PlayIQColors.cardBorder, lineWidth: 1))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            actionButton(title: "Send Reset Code", enabled: !username.isEmpty) {
                Task {
                    await playerStore.forgotPassword(username: username)
                    if playerStore.errorMessage == nil {
                        withAnimation { authMode = .resetPassword }
                    }
                }
            }

            Button(action: {
                withAnimation {
                    authMode = .login
                    playerStore.errorMessage = nil
                    playerStore.successMessage = nil
                }
            }) {
                Text("Back to Login")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.gold.opacity(0.8))
            }
        }
    }

    // MARK: - Reset Password Form

    private var resetPasswordForm: some View {
        VStack(spacing: 16) {
            Text("Enter the 6-character code sent to your parent's email.")
                .font(PlayIQFonts.caption)
                .foregroundColor(PlayIQColors.textSecondary)
                .multilineTextAlignment(.center)

            fieldGroup(label: "Reset Code") {
                TextField("", text: $resetCode)
                    .textFieldStyle(.plain)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .padding(14)
                    .background(PlayIQColors.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PlayIQColors.cardBorder, lineWidth: 1))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            }

            fieldGroup(label: "New Password") {
                SecureField("At least 4 characters", text: $newPassword)
                    .textFieldStyle(.plain)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .padding(14)
                    .background(PlayIQColors.card)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PlayIQColors.cardBorder, lineWidth: 1))
            }

            actionButton(title: "Reset Password", enabled: !resetCode.isEmpty && newPassword.count >= 4) {
                Task {
                    let success = await playerStore.resetPassword(username: username, code: resetCode, newPassword: newPassword)
                    if success {
                        resetSuccess = true
                        password = ""
                        resetCode = ""
                        newPassword = ""
                        playerStore.successMessage = nil
                        withAnimation { authMode = .login }
                    }
                }
            }

            Button(action: {
                withAnimation {
                    authMode = .forgotPassword
                    playerStore.errorMessage = nil
                }
            }) {
                Text("Back")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.gold.opacity(0.8))
            }
        }
    }

    // MARK: - Helpers

    private func fieldGroup<Content: View>(label: String, optional: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(label)
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.textSecondary)
                if let optional = optional {
                    Text("(\(optional))")
                        .font(.system(size: 11))
                        .foregroundColor(PlayIQColors.textSecondary.opacity(0.6))
                }
            }
            content()
        }
    }

    private func actionButton(title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                if playerStore.isLoading {
                    ProgressView()
                        .tint(PlayIQColors.background)
                } else {
                    Text(title)
                        .font(PlayIQFonts.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(PlayIQColors.gold)
            .foregroundColor(PlayIQColors.background)
            .cornerRadius(12)
        }
        .disabled(!enabled || playerStore.isLoading)
        .opacity(enabled ? 1.0 : 0.5)
    }

    private func tabButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(PlayIQFonts.headline)
                .foregroundColor(isActive ? PlayIQColors.gold : PlayIQColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isActive ? PlayIQColors.gold.opacity(0.15) : Color.clear)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(PlayerStore())
        .environmentObject(GameState())
}
