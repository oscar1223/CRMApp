
import Foundation

// MARK: - Client Model
struct Client: Identifiable, Codable {
    let id = UUID()
    var name: String
    var email: String
    var phone: String
    var company: String
    var status: ClientStatus
    var lastContact: Date
    var notes: String
    var tags: [String]
    
    init(name: String, email: String, phone: String, company: String, status: ClientStatus = .prospect, lastContact: Date = Date(), notes: String = "", tags: [String] = []) {
        self.name = name
        self.email = email
        self.phone = phone
        self.company = company
        self.status = status
        self.lastContact = lastContact
        self.notes = notes
        self.tags = tags
    }
}

enum ClientStatus: String, CaseIterable, Codable {
    case prospect = "Prospecto"
    case lead = "Lead"
    case qualified = "Calificado"
    case proposal = "Propuesta"
    case negotiation = "Negociación"
    case closedWon = "Cerrado - Ganado"
    case closedLost = "Cerrado - Perdido"
    
    var color: String {
        switch self {
        case .prospect: return "blue"
        case .lead: return "green"
        case .qualified: return "orange"
        case .proposal: return "purple"
        case .negotiation: return "yellow"
        case .closedWon: return "green"
        case .closedLost: return "red"
        }
    }
}

// MARK: - Task Model
struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var dueDate: Date
    var priority: TaskPriority
    var status: TaskStatus
    var clientId: UUID?
    var assignedTo: String
    var createdAt: Date
    
    init(title: String, description: String, dueDate: Date, priority: TaskPriority = .medium, status: TaskStatus = .pending, clientId: UUID? = nil, assignedTo: String = "Yo") {
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.priority = priority
        self.status = status
        self.clientId = clientId
        self.assignedTo = assignedTo
        self.createdAt = Date()
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    case low = "Baja"
    case medium = "Media"
    case high = "Alta"
    case urgent = "Urgente"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

enum TaskStatus: String, CaseIterable, Codable {
    case pending = "Pendiente"
    case inProgress = "En Progreso"
    case completed = "Completada"
    case cancelled = "Cancelada"
}

// MARK: - Activity Model
struct Activity: Identifiable, Codable {
    let id = UUID()
    var type: ActivityType
    var title: String
    var description: String
    var date: Date
    var clientId: UUID?
    var duration: TimeInterval?
    
    init(type: ActivityType, title: String, description: String, date: Date = Date(), clientId: UUID? = nil, duration: TimeInterval? = nil) {
        self.type = type
        self.title = title
        self.description = description
        self.date = date
        self.clientId = clientId
        self.duration = duration
    }
}

enum ActivityType: String, CaseIterable, Codable {
    case call = "Llamada"
    case email = "Email"
    case meeting = "Reunión"
    case note = "Nota"
    case followUp = "Seguimiento"
    
    var icon: String {
        switch self {
        case .call: return "phone"
        case .email: return "envelope"
        case .meeting: return "calendar"
        case .note: return "note.text"
        case .followUp: return "arrow.clockwise"
        }
    }
}

// MARK: - Dashboard Metrics
struct DashboardMetrics {
    var totalClients: Int
    var newLeads: Int
    var pendingTasks: Int
    var closedDeals: Int
    var revenue: Double
    
    init() {
        self.totalClients = 0
        self.newLeads = 0
        self.pendingTasks = 0
        self.closedDeals = 0
        self.revenue = 0.0
    }
}
