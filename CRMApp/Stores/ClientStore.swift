import Foundation
import SwiftUI

// MARK: - Client Store
final class ClientStore: ObservableObject {
    @Published var clients: [Client] = []
    private let key = "Clients.v1"
    
    init() {
        loadClients()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(clients) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func loadClients() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Client].self, from: data) {
            self.clients = decoded
        } else {
            // Add some sample clients
            self.clients = [
                Client(name: "María García", email: "maria@email.com", phone: "+34 600 123 456", notes: "Cliente frecuente, prefiere citas matutinas"),
                Client(name: "Juan Pérez", email: "juan@email.com", phone: "+34 600 789 012", notes: "Primera consulta"),
                Client(name: "Ana López", email: "ana@email.com", phone: "+34 600 345 678", notes: "Cliente VIP")
            ]
        }
    }
    
    func addClient(_ client: Client) {
        clients.append(client)
        save()
    }
    
    func updateClient(_ client: Client) {
        if let index = clients.firstIndex(where: { $0.id == client.id }) {
            clients[index] = client
            save()
        }
    }
    
    func deleteClient(_ client: Client) {
        clients.removeAll { $0.id == client.id }
        save()
    }
}
