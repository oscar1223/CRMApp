import Foundation

// MARK: - Event Model
struct MockEvent: Identifiable, Codable {
    let id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    
    init(title: String, startDate: Date, endDate: Date, isAllDay: Bool = false) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Hashable {
    enum Role: String, Codable { 
        case user = "user"
        case bot = "bot"
    }
    
    let id = UUID()
    let role: Role
    let text: String
    let timestamp: Date
    
    init(role: Role, text: String, timestamp: Date = Date()) {
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }
}

// MARK: - Chat Conversation Model
struct ChatConversation: Identifiable, Hashable {
    enum ChatFolder: String, CaseIterable {
        case general = "General"
        case work = "Trabajo"
        case personal = "Personal"
        case archive = "Archivo"
        
        var icon: String {
            switch self {
            case .general: return "folder"
            case .work: return "briefcase"
            case .personal: return "person"
            case .archive: return "archivebox"
            }
        }
        
        var color: String {
            switch self {
            case .general: return "blue"
            case .work: return "purple"
            case .personal: return "green"
            case .archive: return "gray"
            }
        }
    }
    
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    var folder: ChatFolder
    var lastUpdated: Date
    
    init(id: UUID = UUID(), title: String, messages: [ChatMessage] = [], folder: ChatFolder = .general, lastUpdated: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.folder = folder
        self.lastUpdated = lastUpdated
    }
    
    var lastMessage: ChatMessage? {
        messages.last
    }
    
    var preview: String {
        lastMessage?.text.prefix(50).description ?? "Sin mensajes"
    }
}
