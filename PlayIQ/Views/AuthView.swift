import SwiftUI

struct AuthView: View {
    @EnvironmentObject var playerStore: PlayerStore
    @State private var isSignup = false
    @State private var username = ""
    @State private var displayName = ""

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            VStack(spacing: 8) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 60))
                    .foregroundColor(PlayIQColors.gold)

                Text("PLAY IQ")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(PlayIQColors.text)

                Text("Learn the Game. Play the Game.")
                    .font(PlayIQFonts.callout)
                    .foregroundColor(PlayIQColors.textSecondary)
            }
            .padding(.bottom, 48)

            // Tab Picker
            HStack(spacing: 0) {
                tabButton(title: "Sign In", isActive: !isSignup) {
                    withAnimation { isSignup = false }
                }
                tabButton(title: "I'm New", isActive: isSignup) {
                    withAnimation { isSignup = true }
                }
            }
            .background(PlayIQColors.card)
            .cornerRadius(12)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)

            // Form
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .font(PlayIQFonts.caption)
                        .foregroundColor(PlayIQColors.textSecondary)

                    TextField("", text: $username)
                        .textFieldStyle(.plain)
                        .font(PlayIQFonts.body)
                        .foregroundColor(PlayIQColors.text)
                        .padding(14)
                        .background(PlayIQColors.card)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(PlayIQColors.cardBorder, lineWidth: 1)
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                if isSignup {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Display Name (optional)")
                            .font(PlayIQFonts.caption)
                            .foregroundColor(PlayIQColors.textSecondary)

                        TextField("", text: $displayName)
                            .textFieldStyle(.plain)
                            .font(PlayIQFonts.body)
                            .foregroundColor(PlayIQColors.text)
                            .padding(14)
                            .background(PlayIQColors.card)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(PlayIQColors.cardBorder, lineWidth: 1)
                            )
                            .autocorrectionDisabled()
                    }
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

                Button(action: submit) {
                    HStack {
                        if playerStore.isLoading {
                            ProgressView()
                                .tint(PlayIQColors.background)
                        } else {
                            Text(isSignup ? "Create Player" : "Let's Play!")
                                .font(PlayIQFonts.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(PlayIQColors.gold)
                    .foregroundColor(PlayIQColors.background)
                    .cornerRadius(12)
                }
                .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty || playerStore.isLoading)
                .opacity(username.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
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
            .padding(.bottom, 40)
        }
        .background(PlayIQColors.background.ignoresSafeArea())
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

    private func submit() {
        Task {
            if isSignup {
                await playerStore.signup(username: username, displayName: displayName)
            } else {
                await playerStore.login(username: username)
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(PlayerStore())
        .environmentObject(GameState())
}
