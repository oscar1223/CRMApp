import Foundation

// MARK: - Client Model
struct Client: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let email: String
    let phone: String
    let totalSpent: Double
}

// MARK: - Mock Data
extension Client {
    static let mock: [Client] = [
        Client(name: "Cliente Prueba", email: "cliente.prueba@example.com", phone: "+34 600 000 000", totalSpent: 1250.0),
        Client(name: "María García", email: "maria.garcia@example.com", phone: "+34 611 223 344", totalSpent: 890.5),
        Client(name: "Juan Pérez", email: "juan.perez@example.com", phone: "+34 622 334 455", totalSpent: 1520.75)
    ]
}


