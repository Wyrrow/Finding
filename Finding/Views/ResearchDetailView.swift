import SwiftUI

struct ResearchDetailView: View {
    let model: FindingViewModel
    let research: Research

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ResearchDetailHeader(model: model, research: research)
                FindingSection(research: research)
                WhyItMattersSection(text: research.whyItMatters)
                ResearchMetadataSection(research: research)
                SourceLinkSection(url: research.source)
                saveButton
                Text("Saved by \(research.savesCount.formatted()) people")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(Color(uiColor: .systemBackground))
        .onAppear { model.deactivateTabBar() }
        .onDisappear { model.activateTabBar() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    model.toggleSaved(research.id)
                } label: {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(isSaved ? "Remove saved study" : "Save study")
            }
        }
    }

    private var isSaved: Bool {
        model.savedResearchIDs.contains(research.id)
    }

    private var saveButton: some View {
        Button {
            model.toggleSaved(research.id)
        } label: {
            Label(isSaved ? "Remove saved study" : "Save study", systemImage: isSaved ? "bookmark.slash" : "bookmark.fill")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

struct ResearchDetailHeader: View {
    let model: FindingViewModel
    let research: Research

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(topicName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FindingTheme.cornflower)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(FindingTheme.softBlue, in: Capsule())

            Text(research.displayTitle)
                .font(.largeTitle.weight(.semibold))
                .fontDesign(.serif)

            Text(research.shortSummary)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var topicName: String {
        model.topics.first(where: { research.topicIds.contains($0.id) })?.name ?? "Research"
    }
}

struct FindingSection: View {
    let research: Research

    var body: some View {
        SectionCard {
            Label("What researchers found", systemImage: "chart.bar.fill")
                .font(.title3.weight(.semibold))
                .fontDesign(.serif)
                .foregroundStyle(.primary)
                .symbolRenderingMode(.hierarchical)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(research.keyFindings, id: \.self) { finding in
                    Text(finding)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.leading, 28)
        }
    }
}

struct WhyItMattersSection: View {
    let text: String

    var body: some View {
        SectionCard {
            Label("Why it matters", systemImage: "heart.fill")
                .font(.title3.weight(.semibold))
                .fontDesign(.serif)
                .foregroundStyle(.primary)
                .symbolRenderingMode(.hierarchical)
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.leading, 28)
        }
    }
}

struct ResearchMetadataSection: View {
    let research: Research

    var body: some View {
        SectionCard {
            VStack(spacing: 12) {
                MetadataRow(icon: "doc.text", label: "Source", value: "\(research.journalName) (\(research.publicationYear))")
                MetadataRow(icon: "checklist", label: "Study type", value: research.studyType?.title ?? "Not reported")
                MetadataRow(icon: "person.2", label: "Participants", value: participantText)
                MetadataRow(icon: "circle.grid.2x2", label: "Evidence quality", value: research.evidenceQuality.title)
            }
        }
    }

    private var participantText: String {
        guard let count = research.participantsCount else { return "Not reported" }
        return "\(count.formatted()) participants"
    }
}

struct MetadataRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        ViewThatFits {
            HStack(alignment: .firstTextBaseline) {
                Label(label, systemImage: icon)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(value)
                    .multilineTextAlignment(.trailing)
            }
            VStack(alignment: .leading, spacing: 4) {
                Label(label, systemImage: icon)
                    .foregroundStyle(.secondary)
                Text(value)
            }
        }
        .font(.subheadline)
    }
}

struct SourceLinkSection: View {
    let url: URL?

    var body: some View {
        if let url {
            Link(destination: url) {
                Label("Read the original source", systemImage: "arrow.up.right.square")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(FindingTheme.card, in: RoundedRectangle(cornerRadius: 16))
            }
            .foregroundStyle(.primary)
        }
    }
}
