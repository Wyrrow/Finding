import SwiftUI

struct FeedView: View {
    let model: FindingViewModel
    @State private var showingFilters = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                FindingLogoView()
                TopicSelector(model: model)
                stateContent
            }
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemBackground))
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingFilters) {
            FilterSheet(model: model)
                .presentationDetents([.medium, .large])
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        switch model.loadState {
        case .loading:
            LoadingView()
        case .failed(let message):
            ErrorView(message: message) {
                Task { await model.load() }
            }
        case .loaded:
            if model.selectedTopicID == "my-feed" {
                FeedResearchSection(model: model)
            } else {
                CategoryResearchSection(model: model, showingFilters: $showingFilters)
            }
        }
    }
}

struct TopicSelector: View {
    let model: FindingViewModel

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 8) {
                ForEach(model.topics) { topic in
                    TopicChipView(title: topic.name, isSelected: model.selectedTopicID == topic.id) {
                        model.selectedTopicID = topic.id
                        model.clearFilters()
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }
}

struct FeedResearchSection: View {
    let model: FindingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today for you")
                .font(.title2.weight(.semibold))
                .fontDesign(.serif)

            if model.feedResearch.isEmpty {
                EmptyStateView(
                    systemImage: "sparkles",
                    title: "Your feed is taking shape",
                    message: "Select at least one research topic in Profile to see personalized studies."
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(model.feedResearch) { research in
                        ResearchNavigationCard(model: model, research: research)
                    }
                }
            }
        }
    }
}

struct CategoryResearchSection: View {
    let model: FindingViewModel
    @Binding var showingFilters: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(model.selectedTopic?.name ?? "Research")
                .font(.largeTitle.weight(.semibold))
                .fontDesign(.serif)
            Text(model.selectedTopic?.description ?? "")
                .font(.body)
                .foregroundStyle(.secondary)

            ViewThatFits {
                HStack {
                    filterButton
                    Spacer()
                    sortMenu
                }
                VStack(alignment: .leading, spacing: 10) {
                    filterButton
                    sortMenu
                }
            }

            if model.feedResearch.isEmpty {
                if model.filter.isEmpty {
                    EmptyStateView(
                        systemImage: "line.3.horizontal.decrease.circle",
                        title: "No studies yet",
                        message: "New research for this topic will appear here."
                    )
                } else {
                    EmptyStateView(
                        systemImage: "line.3.horizontal.decrease.circle",
                        title: "No matching studies",
                        message: "Try clearing your filters to see more research.",
                        actionTitle: "Clear filters",
                        action: { model.clearFilters() }
                    )
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(model.feedResearch) { research in
                        ResearchNavigationCard(model: model, research: research)
                    }
                }
            }
        }
    }

    private var filterButton: some View {
        Button {
            showingFilters = true
        } label: {
            Label("Filter\(model.filter.count > 0 ? " (\(model.filter.count))" : "")", systemImage: "line.3.horizontal.decrease")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(FindingTheme.card, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var sortMenu: some View {
        Menu {
            ForEach(ResearchSort.allCases) { option in
                Button {
                    model.sort = option
                } label: {
                    if option == model.sort {
                        Label(option.rawValue, systemImage: "checkmark")
                    } else {
                        Text(option.rawValue)
                    }
                }
            }
        } label: {
            HStack {
                Text("Sort: \(model.sort.rawValue)")
                Image(systemName: "chevron.down")
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(FindingTheme.card, in: Capsule())
        }
        .foregroundStyle(.primary)
    }
}

struct ResearchNavigationCard: View {
    let model: FindingViewModel
    let research: Research

    var body: some View {
        NavigationLink {
            ResearchDetailView(model: model, research: research)
        } label: {
            ResearchCardView(
                research: research,
                topicName: topicName,
                isSaved: model.savedResearchIDs.contains(research.id)
            ) {
                model.toggleSaved(research.id)
            }
        }
        .buttonStyle(.plain)
    }

    private var topicName: String {
        model.topics.first(where: { research.topicIds.contains($0.id) })?.name ?? "Research"
    }
}

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    let model: FindingViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Evidence quality") {
                    ForEach(EvidenceQuality.allCases) { quality in
                        selectionRow(quality.title, selected: model.filter.qualities.contains(quality)) {
                            toggle(quality, in: &model.filter.qualities)
                        }
                    }
                }

                Section("Study type") {
                    ForEach(ResearchStudyType.allCases) { type in
                        selectionRow(type.title, selected: model.filter.studyTypes.contains(type)) {
                            toggle(type, in: &model.filter.studyTypes)
                        }
                    }
                }

                Section("Publication year") {
                    ForEach([2024, 2023, 2022], id: \.self) { year in
                        selectionRow(year.formatted(.number.grouping(.never)), selected: model.filter.publicationYear == year) {
                            model.filter.publicationYear = model.filter.publicationYear == year ? nil : year
                        }
                    }
                }
            }
            .navigationTitle("Filter research")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") { model.clearFilters() }
                        .disabled(model.filter.isEmpty)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func selectionRow(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(FindingTheme.cornflower)
                }
            }
        }
        .foregroundStyle(.primary)
    }

    private func toggle<T: Hashable>(_ value: T, in set: inout Set<T>) {
        if set.contains(value) {
            set.remove(value)
        } else {
            set.insert(value)
        }
    }
}
