import SwiftUI

struct ProfileView: View {
    let model: FindingViewModel
    @State private var showingConnectEmail = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Your preferences. A more relevant feed.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                AccountProfileSection(
                    displayName: model.accountDisplayName,
                    hasConnectedEmail: model.accountEmail != nil,
                    onConnect: { showingConnectEmail = true },
                    onSignOut: model.signOut
                )
                Divider()
                TopicPreferencesSection(model: model)
                Divider()
                NotificationPreferencesSection(model: model)
                Divider()
                AppPreferencesSection(model: model)
                ProfileSaveSection(model: model)
                DeleteAccountSection {
                    showingDeleteConfirmation = true
                }
            }
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
            .padding()
            .padding(.bottom, 84)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingConnectEmail) {
            ConnectEmailView(model: model)
                .presentationDetents([.height(310)])
        }
        .alert("Delete account?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete account", role: .destructive) {
                model.deleteAccount()
            }
        } message: {
            Text("Your connected email, saved studies and preferences will be removed from this device. This action cannot be undone.")
        }
    }
}

struct AccountProfileSection: View {
    let displayName: String
    let hasConnectedEmail: Bool
    let onConnect: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profile")
                .font(.title2.weight(.semibold))
                .fontDesign(.serif)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 20) {
                    ProfileAvatarView()
                    AccountDetailsView(
                        displayName: displayName,
                        hasConnectedEmail: hasConnectedEmail,
                        onConnect: onConnect,
                        onSignOut: onSignOut
                    )
                }
                VStack(alignment: .leading, spacing: 16) {
                    ProfileAvatarView()
                    AccountDetailsView(
                        displayName: displayName,
                        hasConnectedEmail: hasConnectedEmail,
                        onConnect: onConnect,
                        onSignOut: onSignOut
                    )
                }
            }
        }
    }
}

struct ProfileAvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.3))
            Image("CornflowerProfile")
                .resizable()
                .scaledToFit()
                .padding(10)
        }
        .frame(width: 92, height: 92)
        .accessibilityLabel("Cornflower profile image")
    }
}

struct AccountDetailsView: View {
    let displayName: String
    let hasConnectedEmail: Bool
    let onConnect: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(displayName)
                .font(.body)
                .textSelection(.enabled)

            if !hasConnectedEmail {
                Button("Connect email", action: onConnect)
                    .buttonStyle(ProfileOutlineButtonStyle())
            }

            Button("Sign out", action: onSignOut)
                .buttonStyle(ProfileOutlineButtonStyle())
        }
        .frame(maxWidth: 260, alignment: .leading)
    }
}

struct ProfileOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(Color.clear, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.primary.opacity(configuration.isPressed ? 0.5 : 0.85), lineWidth: 1)
            }
    }
}

struct ConnectEmailView: View {
    @Environment(\.dismiss) private var dismiss
    let model: FindingViewModel
    @State private var email = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Connect your email")
                    .font(.title2.weight(.semibold))
                    .fontDesign(.serif)
                Text("Use an email address to identify your account on this device.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                TextField("name@example.com", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(FindingTheme.card, in: RoundedRectangle(cornerRadius: 12))

                if let validationMessage {
                    Text(validationMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button("Connect email") {
                    if model.connectEmail(email) {
                        dismiss()
                    } else {
                        validationMessage = "Enter a valid email address."
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct TopicPreferencesSection: View {
    let model: FindingViewModel
    private let columns = [GridItem(.adaptive(minimum: 145), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Topics you’re interested in")
                .font(.title2.weight(.semibold))
                .fontDesign(.serif)
            Text("Select all that apply.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                ForEach(model.topics.filter { $0.id != "my-feed" }) { topic in
                    let selected = model.profile.topicIDs.contains(topic.id)
                    Button {
                        model.updateProfile { profile in
                            if selected {
                                profile.topicIDs.remove(topic.id)
                            } else {
                                profile.topicIDs.insert(topic.id)
                            }
                        }
                    } label: {
                        Label(topic.name, systemImage: selected ? "checkmark.circle.fill" : "circle")
                            .font(.subheadline)
                            .foregroundStyle(selected ? FindingTheme.cornflower : Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(FindingTheme.card, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
        }
    }
}

struct NotificationPreferencesSection: View {
    let model: FindingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.title2.weight(.semibold))
                .fontDesign(.serif)
            Text("Get notified about new research in your topics.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Toggle(isOn: Binding(
                get: { model.profile.newRecommendations },
                set: { value in model.updateProfile { $0.newRecommendations = value } }
            )) {
                Label("New study recommendations", systemImage: "bell")
            }
            Toggle(isOn: Binding(
                get: { model.profile.weeklyDigest },
                set: { value in model.updateProfile { $0.weeklyDigest = value } }
            )) {
                Label("Weekly digest", systemImage: "envelope")
            }
        }
        .tint(FindingTheme.cornflower)
    }
}

struct AppPreferencesSection: View {
    let model: FindingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App settings")
                .font(.title2.weight(.semibold))
                .fontDesign(.serif)

            PreferencePickerRow(title: "Language", systemImage: "globe", value: model.profile.language.title) {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        model.updateProfile { $0.language = language }
                    } label: {
                        if model.profile.language == language {
                            Label(language.title, systemImage: "checkmark")
                        } else {
                            Text(language.title)
                        }
                    }
                }
            }

            PreferencePickerRow(title: "Theme", systemImage: "circle.lefthalf.filled", value: model.profile.theme.title) {
                ForEach(AppTheme.allCases) { theme in
                    Button {
                        model.updateProfile { $0.theme = theme }
                    } label: {
                        if model.profile.theme == theme {
                            Label(theme.title, systemImage: "checkmark")
                        } else {
                            Text(theme.title)
                        }
                    }
                }
            }
        }
    }
}

struct PreferencePickerRow<MenuContent: View>: View {
    let title: String
    let systemImage: String
    let value: String
    @ViewBuilder let menuContent: MenuContent

    var body: some View {
        Menu {
            menuContent
        } label: {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .font(.body)
            .padding(.vertical, 8)
        }
        .foregroundStyle(.primary)
    }
}

struct ProfileSaveSection: View {
    let model: FindingViewModel

    var body: some View {
        VStack(spacing: 10) {
            Button {
                Task { await model.saveProfile() }
            } label: {
                if model.profileSaveState == .saving {
                    ProgressView()
                        .tint(Color(uiColor: .systemBackground))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Save changes")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.45)

            switch model.profileSaveState {
            case .success:
                Label("Preferences saved", systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        model.dismissProfileResult()
                    }
            case .failure(let message):
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            default:
                EmptyView()
            }
        }
    }

    private var canSave: Bool {
        model.profileSaveState == .changed || {
            if case .failure = model.profileSaveState { return true }
            return false
        }()
    }
}

struct DeleteAccountSection: View {
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Label("Delete account", systemImage: "trash")
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.red)
        .accessibilityHint("Deletes your local account data after confirmation")
    }
}
