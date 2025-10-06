import Foundation
import SwiftData

// MARK: - Artist Status Enum
enum ArtistStatus: String, Codable {
    case active = "active"
    case inactive = "inactive"
    case vacation = "vacation"

    var displayName: String {
        switch self {
        case .active: return "Activo"
        case .inactive: return "Inactivo"
        case .vacation: return "Vacaciones"
        }
    }

    var color: String {
        switch self {
        case .active: return "successGreen"
        case .inactive: return "textTertiary"
        case .vacation: return "warningOrange"
        }
    }
}

// MARK: - Artist Model
@Model
class Artist {
    var id: UUID
    var name: String
    var email: String
    var phone: String
    var specialty: String
    var status: ArtistStatus
    var joinedDate: Date
    var avatarColor: String // For avatar background gradient

    // Stats
    var totalAppointments: Int
    var monthlyRevenue: Double
    var rating: Double

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        phone: String,
        specialty: String,
        status: ArtistStatus = .active,
        joinedDate: Date = Date(),
        avatarColor: String = "brandPrimary",
        totalAppointments: Int = 0,
        monthlyRevenue: Double = 0,
        rating: Double = 5.0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.specialty = specialty
        self.status = status
        self.joinedDate = joinedDate
        self.avatarColor = avatarColor
        self.totalAppointments = totalAppointments
        self.monthlyRevenue = monthlyRevenue
        self.rating = rating
    }

    // Helper to get initials
    var initials: String {
        let components = name.split(separator: " ")
        let first = components.first?.first.map(String.init) ?? "A"
        let last = components.dropFirst().first?.first.map(String.init) ?? ""
        return first + last
    }
}

// MARK: - Mock Data
extension Artist {
    static var mock: [Artist] {
        [
            Artist(
                name: "María González",
                email: "maria@studio.com",
                phone: "+34 611 222 333",
                specialty: "Realismo",
                status: .active,
                avatarColor: "brandPrimary",
                totalAppointments: 145,
                monthlyRevenue: 3250.0,
                rating: 4.9
            ),
            Artist(
                name: "Carlos Ruiz",
                email: "carlos@studio.com",
                phone: "+34 622 333 444",
                specialty: "Japonés",
                status: .active,
                avatarColor: "calendarEventBlue",
                totalAppointments: 132,
                monthlyRevenue: 2980.0,
                rating: 4.8
            ),
            Artist(
                name: "Ana Martínez",
                email: "ana@studio.com",
                phone: "+34 633 444 555",
                specialty: "Minimalista",
                status: .vacation,
                avatarColor: "calendarEventPink",
                totalAppointments: 98,
                monthlyRevenue: 2100.0,
                rating: 4.95
            ),
            Artist(
                name: "David López",
                email: "david@studio.com",
                phone: "+34 644 555 666",
                specialty: "Tradicional",
                status: .active,
                avatarColor: "calendarEventOrange",
                totalAppointments: 167,
                monthlyRevenue: 3500.0,
                rating: 4.85
            )
        ]
    }
}
