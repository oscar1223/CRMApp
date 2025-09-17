import Foundation

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}


