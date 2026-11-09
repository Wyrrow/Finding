import SwiftUI

enum FindingTheme {
    static let cornflower = Color(red: 0.29, green: 0.49, blue: 0.96)
    static let card = Color(uiColor: .secondarySystemBackground)
    static let softBlue = Color(red: 0.93, green: 0.95, blue: 1)
}

struct FindingLogoView: View {
    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Image("MainFlower")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 62, height: 48)
                    .offset(x: 7, y: 1)
                    .accessibilityHidden(true)
                Text("Finding")
                    .font(.title3.weight(.semibold))
                    .fontDesign(.serif)
            }
            Text("Real research. A healthier for you.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct TopicChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(isSelected ? Color.primary : FindingTheme.card, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct EvidenceBadgeView: View {
    let quality: EvidenceQuality

    var body: some View {
        Label {
            Text("\(quality.title) quality evidence")
        } icon: {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var color: Color {
        switch quality {
        case .high: .green
        case .moderate: .orange
        case .emerging: FindingTheme.cornflower
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.primary)
            Text("Finding research for you…")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 280)
        .accessibilityElement(children: .combine)
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        EmptyStateView(
            systemImage: "exclamationmark.circle",
            title: "Something went wrong",
            message: message,
            actionTitle: "Retry",
            action: retry
        )
    }
}

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(FindingTheme.cornflower)
            Text(title)
                .font(.title3.weight(.semibold))
                .fontDesign(.serif)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
            }
        }
        .frame(maxWidth: 460, minHeight: 280)
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct SectionCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(FindingTheme.card, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color(uiColor: .systemBackground))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.primary.opacity(configuration.isPressed ? 0.75 : 1), in: Capsule())
    }
}
