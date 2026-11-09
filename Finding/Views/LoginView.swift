import SwiftUI

struct LoginView: View {
    let model: FindingViewModel
    @State private var signingInProvider: AccountProvider?

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer(minLength: 28)
                LoginHeroView()
                LoginOptionsCard(
                    signingInProvider: signingInProvider,
                    onSelect: startSession
                )
                LoginPrivacyNote()
                Spacer(minLength: 20)
            }
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity, minHeight: 700)
            .padding(.horizontal, 22)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private func startSession(_ provider: AccountProvider) {
        guard signingInProvider == nil else { return }
        signingInProvider = provider
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            model.startSession(with: provider)
            signingInProvider = nil
        }
    }
}

struct LoginHeroView: View {
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Image("MainFlower")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 155)
                    .accessibilityHidden(true)

                Text("Finding")
                    .font(.largeTitle.weight(.semibold))
                    .fontDesign(.serif)
                    .foregroundStyle(.primary)
            }

            VStack(spacing: 8) {
                Text("Research that understands you")
                    .font(.title2.weight(.semibold))
                    .fontDesign(.serif)
                    .multilineTextAlignment(.center)

                Text("Finding is a charitable project created to make trustworthy women’s health research easier to understand and access.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text("Explore clear, personalized summaries and save the studies that matter to you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct LoginOptionsCard: View {
    let signingInProvider: AccountProvider?
    let onSelect: (AccountProvider) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Continue to Finding")
                .font(.title3.weight(.semibold))
                .fontDesign(.serif)
                .frame(maxWidth: .infinity, alignment: .leading)

            LoginProviderButton(
                title: "Continue as guest",
                systemImage: "person",
                provider: .guest,
                style: .primary,
                signingInProvider: signingInProvider,
                action: onSelect
            )

            LoginProviderButton(
                title: "Continue with Apple",
                systemImage: "apple.logo",
                provider: .apple,
                style: .outline,
                signingInProvider: signingInProvider,
                action: onSelect
            )

            LoginProviderButton(
                title: "Continue with Google",
                provider: .google,
                style: .outline,
                signingInProvider: signingInProvider,
                action: onSelect
            )
        }
        .padding(18)
        .background(FindingTheme.card.opacity(0.75), in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.secondary.opacity(0.12))
        }
    }
}

enum LoginButtonStyle: Equatable {
    case primary
    case outline
}

struct LoginProviderButton: View {
    let title: String
    var systemImage: String?
    let provider: AccountProvider
    let style: LoginButtonStyle
    let signingInProvider: AccountProvider?
    let action: (AccountProvider) -> Void

    var body: some View {
        Button {
            action(provider)
        } label: {
            HStack(spacing: 10) {
                providerIcon
                    .frame(width: 22)

                Text(title)
                    .frame(maxWidth: .infinity)

                if signingInProvider == provider {
                    ProgressView()
                        .tint(foregroundColor)
                } else {
                    Color.clear
                        .frame(width: 22, height: 1)
                }
            }
            .font(.headline)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(backgroundStyle, in: Capsule())
            .overlay {
                if style == .outline {
                    Capsule()
                        .stroke(Color.primary.opacity(0.75), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(signingInProvider != nil)
        .opacity(signingInProvider == nil || signingInProvider == provider ? 1 : 0.5)
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var providerIcon: some View {
        if let systemImage {
            Image(systemName: systemImage)
        } else {
            Text("G")
                .font(.headline.weight(.bold))
                .foregroundStyle(FindingTheme.cornflower)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: Color(uiColor: .systemBackground)
        case .outline: .primary
        }
    }

    private var backgroundStyle: Color {
        switch style {
        case .primary: .primary
        case .outline: .clear
        }
    }
}

struct LoginPrivacyNote: View {
    var body: some View {
        Text("Finding provides educational research summaries and does not replace professional medical advice, diagnosis or treatment.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

#Preview {
    LoginView(model: FindingViewModel())
}
