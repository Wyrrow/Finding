import SwiftUI

struct SavedStudiesView: View {
    let model: FindingViewModel
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                FindingLogoView()
                Text("Your saved studies")
                    .font(.largeTitle.weight(.semibold))
                    .fontDesign(.serif)
                Text("The research you want to come back to.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                if model.savedResearch.isEmpty {
                    EmptyStateView(
                        systemImage: "bookmark",
                        title: "No saved studies yet",
                        message: "Tap the bookmark on any study to keep it here."
                    )
                } else if results.isEmpty {
                    EmptyStateView(
                        systemImage: "magnifyingglass",
                        title: "No search results",
                        message: "Try another title, topic or journal."
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(results) { research in
                            ResearchNavigationCard(model: model, research: research)
                        }
                    }
                }
            }
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .searchable(text: $searchText, prompt: "Search your saved studies")
        .toolbar(.hidden, for: .navigationBar)
    }

    private var results: [Research] {
        guard !searchText.isEmpty else { return model.savedResearch }
        return model.savedResearch.filter {
            $0.displayTitle.localizedStandardContains(searchText)
            || $0.journalName.localizedStandardContains(searchText)
            || $0.topicIds.contains { $0.localizedStandardContains(searchText) }
        }
    }
}
