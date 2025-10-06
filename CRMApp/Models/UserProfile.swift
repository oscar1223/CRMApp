import Foundation
import SwiftData

// MARK: - Account Type Enum
enum AccountType: String, Codable {
    case individual    // Tatuador individual
    case studio       // Gestor de estudio
    case hybrid       // Ambos

    var displayName: String {
        switch self {
        case .individual: return "Tatuador Individual"
        case .studio: return "Estudio"
        case .hybrid: return "Estudio + Tatuador"
        }
    }

    var description: String {
        switch self {
        case .individual: return "Gestiona tu agenda personal y clientes"
        case .studio: return "Administra tu estudio y equipo de artistas"
        case .hybrid: return "Combina gestión de estudio con tu trabajo personal"
        }
    }

    var icon: String {
        switch self {
        case .individual: return "person.fill"
        case .studio: return "building.2.fill"
        case .hybrid: return "person.2.fill"
        }
    }
}

// MARK: - User Profile Model
@Model
class UserProfile {
    var accountType: AccountType
    var onboardingCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    // User info (optional for now)
    var artistName: String?
    var studioName: String?

    init(
        accountType: AccountType,
        onboardingCompleted: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        artistName: String? = nil,
        studioName: String? = nil
    ) {
        self.accountType = accountType
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.artistName = artistName
        self.studioName = studioName
    }

    // Helper to check capabilities
    func hasStudioAccess() -> Bool {
        accountType == .studio || accountType == .hybrid
    }

    func hasIndividualAccess() -> Bool {
        accountType == .individual || accountType == .hybrid
    }
}
