import Foundation

enum LoadState: Equatable {
    case loading
    case loaded
    case failed(String)
}

enum ResearchSort: String, CaseIterable, Identifiable {
    case mostRelevant = "Most relevant"
    case newest = "Newest"
    case mostSaved = "Most saved"

    var id: Self { self }
}

struct ResearchFilter: Equatable {
    var qualities: Set<EvidenceQuality> = []
    var studyTypes: Set<ResearchStudyType> = []
    var publicationYear: Int?

    var count: Int {
        qualities.count + studyTypes.count + (publicationYear == nil ? 0 : 1)
    }

    var isEmpty: Bool { count == 0 }

    mutating func clear() {
        qualities.removeAll()
        studyTypes.removeAll()
        publicationYear = nil
    }
}

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system
    case english
    case russian

    var id: Self { self }

    var title: String {
        switch self {
        case .system: "System"
        case .english: "English"
        case .russian: "Русский"
        }
    }
}

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }

    var title: String {
        switch self {
        case .system: "Auto"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

enum AccountProvider: String, Codable {
    case guest
    case apple
    case google

    var title: String {
        switch self {
        case .guest: "Guest"
        case .apple: "Apple account"
        case .google: "Google account"
        }
    }
}

struct ProfilePreferences: Codable, Equatable {
    var topicIDs: Set<String> = ["cycle-health", "hormones", "mental-health", "nutrition"]
    var newRecommendations = true
    var weeklyDigest = true
    var language = AppLanguage.system
    var theme = AppTheme.system

    private enum CodingKeys: String, CodingKey {
        case topicIDs
        case newRecommendations
        case weeklyDigest
        case language
        case theme
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        topicIDs = try container.decodeIfPresent(Set<String>.self, forKey: .topicIDs) ?? topicIDs
        newRecommendations = try container.decodeIfPresent(Bool.self, forKey: .newRecommendations) ?? newRecommendations
        weeklyDigest = try container.decodeIfPresent(Bool.self, forKey: .weeklyDigest) ?? weeklyDigest
        language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .system
        theme = try container.decodeIfPresent(AppTheme.self, forKey: .theme) ?? .system
    }
}

protocol ResearchRepository: Sendable {
    func fetchResearch() async throws -> [Research]
    func fetchTopics() async throws -> [Topic]
}

struct MockResearchRepository: ResearchRepository {
    func fetchResearch() async throws -> [Research] {
        try await Task.sleep(for: .milliseconds(250))
        return MockResearchData.researches
    }

    func fetchTopics() async throws -> [Topic] {
        try await Task.sleep(for: .milliseconds(100))
        return MockResearchData.topics
    }
}
