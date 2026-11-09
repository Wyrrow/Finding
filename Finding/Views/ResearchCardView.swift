import SwiftUI

struct ResearchCardView: View {
    let research: Research
    let topicName: String
    let isSaved: Bool
    let onToggleSaved: () -> Void

    var body: some View {
        ZStack(alignment: .trailing) {
            cardContent
            Image("CornflowerSprig")
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 84)
                .offset(x: 13, y: 18)
                .accessibilityHidden(true)
        }
        .padding(14)
        .background(FindingTheme.card.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.12))
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top) {
                Text(topicName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.secondary.opacity(0.1), in: Capsule())
                Spacer(minLength: 12)
                Button(action: onToggleSaved) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isSaved ? "Remove saved study" : "Save study")
            }

            Text(research.displayTitle)
                .font(.title3.weight(.semibold))
                .fontDesign(.serif)
                .foregroundStyle(.primary)
                .padding(.trailing, 28)

            Text(research.shortSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.trailing, 22)

            Text("\(research.journalName) · \(research.publicationYear)")
                .font(.caption)
                .foregroundStyle(.secondary)

            ViewThatFits(in: .horizontal) {
                HStack {
                    EvidenceBadgeView(quality: research.evidenceQuality)
                    Spacer()
                    savedLabel
                }
                VStack(alignment: .leading, spacing: 6) {
                    EvidenceBadgeView(quality: research.evidenceQuality)
                    savedLabel
                }
            }
        }
    }

    private var savedLabel: some View {
        Label("\(research.savesCount.formatted(.number.notation(.compactName))) saved", systemImage: "bookmark")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    ResearchCardView(
        research: MockResearchData.researches[0],
        topicName: "Hormones",
        isSaved: false,
        onToggleSaved: {}
    )
    .padding()
}
