import Foundation

struct Research: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let pmid: String?
    let doi: String?
    let originalTitle: String
    let displayTitle: String
    let shortSummary: String
    let keyFindings: [String]
    let whyItMatters: String
    let limitations: String
    let topicIds: [String]
    let authors: [ResearchAuthor]
    let journalName: String
    let publicationDate: Date?
    let sourceURL: String?
    let studyType: ResearchStudyType?
    let participantsCount: Int?
    let evidenceQuality: EvidenceQuality
    let savesCount: Int
    let isVisible: Bool

    var publicationYear: Int {
        guard let publicationDate else { return Calendar.current.component(.year, from: .now) }
        return Calendar.current.component(.year, from: publicationDate)
    }

    var source: URL? {
        guard let sourceURL else { return nil }
        return URL(string: sourceURL)
    }
}

struct ResearchAuthor: Codable, Hashable, Sendable {
    let name: String
    let organization: String?
}

enum ResearchStudyType: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {
    case clinicalTrial
    case metaAnalysis
    case systematicReview
    case observational
    case laboratory
    case review
    case other

    var id: Self { self }

    var title: String {
        switch self {
        case .clinicalTrial: "Clinical trial"
        case .metaAnalysis: "Meta-analysis"
        case .systematicReview: "Systematic review"
        case .observational: "Observational"
        case .laboratory: "Laboratory"
        case .review: "Review"
        case .other: "Other"
        }
    }
}

enum EvidenceQuality: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {
    case high
    case moderate
    case emerging

    var id: Self { self }

    var title: String {
        switch self {
        case .high: "High"
        case .moderate: "Moderate"
        case .emerging: "Emerging"
        }
    }
}
