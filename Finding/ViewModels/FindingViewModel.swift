import Foundation
import Observation

enum ProfileSaveState: Equatable {
    case unchanged
    case changed
    case saving
    case success
    case failure(String)
}

@MainActor
@Observable
final class FindingViewModel {
    private let repository: any ResearchRepository
    private let defaults: UserDefaults
    private let savedKey = "finding.savedResearchIDs"
    private let profileKey = "finding.profilePreferences"
    private let accountEmailKey = "finding.accountEmail"
    private let accountProviderKey = "finding.accountProvider"
    private let activeSessionKey = "finding.hasActiveSession"

    var loadState: LoadState = .loading
    var researches: [Research] = []
    var topics: [Topic] = []
    var savedResearchIDs: Set<String>
    var selectedTopicID = "my-feed"
    var sort: ResearchSort = .mostRelevant
    var filter = ResearchFilter()
    var profile: ProfilePreferences
    private(set) var savedProfile: ProfilePreferences
    var profileSaveState: ProfileSaveState = .unchanged
    var accountEmail: String?
    var accountProvider: AccountProvider?
    var hasActiveSession: Bool
    var showsTabBar = true
    private(set) var isTabBarAvailable = true
    @ObservationIgnored private var tabBarHideTask: Task<Void, Never>?

    init(
        repository: (any ResearchRepository)? = nil,
        defaults: UserDefaults = .standard
    ) {
        self.repository = repository ?? MockResearchRepository()
        self.defaults = defaults
        savedResearchIDs = Set(defaults.stringArray(forKey: savedKey) ?? [])
        accountEmail = defaults.string(forKey: accountEmailKey)
        accountProvider = defaults.string(forKey: accountProviderKey).flatMap(AccountProvider.init(rawValue:))
        hasActiveSession = defaults.bool(forKey: activeSessionKey)

        if let data = defaults.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(ProfilePreferences.self, from: data) {
            profile = decoded
            savedProfile = decoded
        } else {
            let initial = ProfilePreferences()
            profile = initial
            savedProfile = initial
        }
    }

    var selectedTopic: Topic? {
        topics.first { $0.id == selectedTopicID }
    }

    var feedResearch: [Research] {
        let visible = researches.filter(\.isVisible)
        let topicFiltered: [Research]
        if selectedTopicID == "my-feed" {
            topicFiltered = visible.filter { research in
                !Set(research.topicIds).isDisjoint(with: profile.topicIDs)
            }
        } else {
            topicFiltered = visible.filter { $0.topicIds.contains(selectedTopicID) }
        }
        return sorted(filtered(topicFiltered))
    }

    var savedResearch: [Research] {
        researches.filter { savedResearchIDs.contains($0.id) }
    }

    func load() async {
        loadState = .loading
        do {
            async let loadedResearch = repository.fetchResearch()
            async let loadedTopics = repository.fetchTopics()
            researches = try await loadedResearch
            topics = try await loadedTopics.sorted { $0.order < $1.order }
            loadState = .loaded
        } catch {
            loadState = .failed("We couldn’t load the latest studies.")
        }
    }

    func toggleSaved(_ researchID: String) {
        if savedResearchIDs.contains(researchID) {
            savedResearchIDs.remove(researchID)
        } else {
            savedResearchIDs.insert(researchID)
        }
        defaults.set(Array(savedResearchIDs), forKey: savedKey)
    }

    func connectEmail(_ email: String) -> Bool {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalized.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil else {
            return false
        }
        accountEmail = normalized
        defaults.set(normalized, forKey: accountEmailKey)
        return true
    }

    var accountDisplayName: String {
        accountEmail ?? accountProvider?.title ?? "Guest"
    }

    func startSession(with provider: AccountProvider) {
        accountProvider = provider
        hasActiveSession = true
        defaults.set(provider.rawValue, forKey: accountProviderKey)
        defaults.set(true, forKey: activeSessionKey)
    }

    func signOut() {
        accountEmail = nil
        accountProvider = nil
        hasActiveSession = false
        defaults.removeObject(forKey: accountEmailKey)
        defaults.removeObject(forKey: accountProviderKey)
        defaults.set(false, forKey: activeSessionKey)
    }

    func deleteAccount() {
        accountEmail = nil
        accountProvider = nil
        hasActiveSession = false
        savedResearchIDs.removeAll()
        let initial = ProfilePreferences()
        profile = initial
        savedProfile = initial
        profileSaveState = .unchanged
        defaults.removeObject(forKey: accountEmailKey)
        defaults.removeObject(forKey: accountProviderKey)
        defaults.set(false, forKey: activeSessionKey)
        defaults.removeObject(forKey: savedKey)
        defaults.removeObject(forKey: profileKey)
    }

    func activateTabBar() {
        isTabBarAvailable = true
        showTabBarTemporarily()
    }

    func deactivateTabBar() {
        isTabBarAvailable = false
        tabBarHideTask?.cancel()
        showsTabBar = false
    }

    func showTabBarTemporarily() {
        guard isTabBarAvailable else { return }
        tabBarHideTask?.cancel()
        showsTabBar = true
        tabBarHideTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            self?.showsTabBar = false
        }
    }

    func updateProfile(_ change: (inout ProfilePreferences) -> Void) {
        change(&profile)
        profileSaveState = profile == savedProfile ? .unchanged : .changed
    }

    func saveProfile() async {
        guard profile != savedProfile else { return }
        profileSaveState = .saving
        do {
            try await Task.sleep(for: .milliseconds(450))
            let data = try JSONEncoder().encode(profile)
            defaults.set(data, forKey: profileKey)
            savedProfile = profile
            profileSaveState = .success
        } catch {
            profileSaveState = .failure("Your preferences couldn’t be saved. Please try again.")
        }
    }

    func dismissProfileResult() {
        profileSaveState = profile == savedProfile ? .unchanged : .changed
    }

    func clearFilters() {
        filter.clear()
    }

    private func filtered(_ input: [Research]) -> [Research] {
        input.filter { research in
            (filter.qualities.isEmpty || filter.qualities.contains(research.evidenceQuality))
            && (filter.studyTypes.isEmpty || research.studyType.map(filter.studyTypes.contains) == true)
            && (filter.publicationYear == nil || research.publicationYear == filter.publicationYear)
        }
    }

    private func sorted(_ input: [Research]) -> [Research] {
        switch sort {
        case .mostRelevant:
            input.sorted { $0.evidenceQuality.rank > $1.evidenceQuality.rank }
        case .newest:
            input.sorted { ($0.publicationDate ?? .distantPast) > ($1.publicationDate ?? .distantPast) }
        case .mostSaved:
            input.sorted { $0.savesCount > $1.savesCount }
        }
    }
}

private extension EvidenceQuality {
    var rank: Int {
        switch self {
        case .high: 3
        case .moderate: 2
        case .emerging: 1
        }
    }
}
