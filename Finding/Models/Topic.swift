import Foundation

struct Topic: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let iconName: String?
    let order: Int
    let isActive: Bool
    let description: String
}
