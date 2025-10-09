import Foundation
import SwiftData

// MARK: - Appointment Status Enum
enum AppointmentStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"

    var displayName: String {
        switch self {
        case .pending: return "Pendiente"
        case .confirmed: return "Confirmada"
        case .inProgress: return "En Progreso"
        case .completed: return "Completada"
        case .cancelled: return "Cancelada"
        case .noShow: return "No Asistió"
        }
    }

    var color: String {
        switch self {
        case .pending: return "warningOrange"
        case .confirmed: return "brandPrimary"
        case .inProgress: return "calendarEventBlue"
        case .completed: return "successGreen"
        case .cancelled: return "textTertiary"
        case .noShow: return "errorRed"
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .inProgress: return "person.fill.checkmark"
        case .completed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        case .noShow: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Appointment Model
@Model
class Appointment {
    var id: UUID
    var clientName: String
    var clientEmail: String
    var clientPhone: String
    var artistId: UUID?
    var artistName: String
    var startDate: Date
    var endDate: Date
    var service: String
    var status: AppointmentStatus
    var price: Double
    var deposit: Double
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        clientName: String,
        clientEmail: String,
        clientPhone: String,
        artistId: UUID? = nil,
        artistName: String,
        startDate: Date,
        endDate: Date,
        service: String,
        status: AppointmentStatus = .pending,
        price: Double = 0,
        deposit: Double = 0,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.clientName = clientName
        self.clientEmail = clientEmail
        self.clientPhone = clientPhone
        self.artistId = artistId
        self.artistName = artistName
        self.startDate = startDate
        self.endDate = endDate
        self.service = service
        self.status = status
        self.price = price
        self.deposit = deposit
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Duration in hours
    var duration: Double {
        endDate.timeIntervalSince(startDate) / 3600
    }

    // Formatted time range
    var timeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - Mock Data
extension Appointment {
    static var mock: [Appointment] {
        let cal = Calendar.current
        let now = Date()

        return [
            Appointment(
                clientName: "Laura Sánchez",
                clientEmail: "laura@example.com",
                clientPhone: "+34 611 222 333",
                artistName: "María González",
                startDate: cal.date(byAdding: .hour, value: 2, to: now) ?? now,
                endDate: cal.date(byAdding: .hour, value: 4, to: now) ?? now,
                service: "Tatuaje Brazo - Realismo",
                status: .confirmed,
                price: 250.0,
                deposit: 50.0,
                notes: "Cliente habitual, prefiere mañanas"
            ),
            Appointment(
                clientName: "Pedro Martínez",
                clientEmail: "pedro@example.com",
                clientPhone: "+34 622 333 444",
                artistName: "Carlos Ruiz",
                startDate: cal.date(byAdding: .day, value: 1, to: now) ?? now,
                endDate: cal.date(byAdding: .day, value: 1, to: cal.date(byAdding: .hour, value: 3, to: now) ?? now) ?? now,
                service: "Dragon Japonés - Espalda",
                status: .pending,
                price: 450.0,
                deposit: 100.0,
                notes: "Primera sesión de 3"
            ),
            Appointment(
                clientName: "Sofia López",
                clientEmail: "sofia@example.com",
                clientPhone: "+34 633 444 555",
                artistName: "Ana Martínez",
                startDate: cal.date(byAdding: .day, value: 2, to: now) ?? now,
                endDate: cal.date(byAdding: .day, value: 2, to: cal.date(byAdding: .hour, value: 1, to: now) ?? now) ?? now,
                service: "Diseño Minimalista - Muñeca",
                status: .confirmed,
                price: 120.0,
                deposit: 30.0
            ),
            Appointment(
                clientName: "Miguel Ángel Torres",
                clientEmail: "miguel@example.com",
                clientPhone: "+34 644 555 666",
                artistName: "David López",
                startDate: cal.date(byAdding: .hour, value: -2, to: now) ?? now,
                endDate: cal.date(byAdding: .hour, value: 1, to: now) ?? now,
                service: "Rosa Tradicional - Hombro",
                status: .inProgress,
                price: 180.0,
                deposit: 40.0
            ),
            Appointment(
                clientName: "Carmen Díaz",
                clientEmail: "carmen@example.com",
                clientPhone: "+34 655 666 777",
                artistName: "María González",
                startDate: cal.date(byAdding: .day, value: -1, to: now) ?? now,
                endDate: cal.date(byAdding: .day, value: -1, to: cal.date(byAdding: .hour, value: 2, to: now) ?? now) ?? now,
                service: "Retrato Realista - Pierna",
                status: .completed,
                price: 320.0,
                deposit: 80.0,
                notes: "Resultado excelente, cliente muy satisfecho"
            )
        ]
    }
}
