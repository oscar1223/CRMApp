import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var clients: [Client] = []
    @Published var tasks: [Task] = []
    @Published var activities: [Activity] = []
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Client Management
    func addClient(_ client: Client) {
        clients.append(client)
        saveData()
    }
    
    func updateClient(_ client: Client) {
        if let index = clients.firstIndex(where: { $0.id == client.id }) {
            clients[index] = client
            saveData()
        }
    }
    
    func deleteClient(_ client: Client) {
        clients.removeAll { $0.id == client.id }
        // Also delete related tasks and activities
        tasks.removeAll { $0.clientId == client.id }
        activities.removeAll { $0.clientId == client.id }
        saveData()
    }
    
    // MARK: - Task Management
    func addTask(_ task: Task) {
        tasks.append(task)
        saveData()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveData()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveData()
    }
    
    // MARK: - Activity Management
    func addActivity(_ activity: Activity) {
        activities.append(activity)
        saveData()
    }
    
    func updateActivity(_ activity: Activity) {
        if let index = activities.firstIndex(where: { $0.id == activity.id }) {
            activities[index] = activity
            saveData()
        }
    }
    
    func deleteActivity(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
        saveData()
    }
    
    // MARK: - Dashboard Metrics
    var dashboardMetrics: DashboardMetrics {
        var metrics = DashboardMetrics()
        metrics.totalClients = clients.count
        metrics.newLeads = clients.filter { $0.status == .lead }.count
        metrics.pendingTasks = tasks.filter { $0.status == .pending }.count
        metrics.closedDeals = clients.filter { $0.status == .closedWon }.count
        // For demo purposes, we'll calculate a simple revenue
        metrics.revenue = Double(metrics.closedDeals) * 1000.0
        return metrics
    }
    
    // MARK: - Sample Data
    private func loadSampleData() {
        // Sample clients
        let client1 = Client(
            name: "Juan Pérez",
            email: "juan.perez@empresa.com",
            phone: "+34 600 123 456",
            company: "Empresa ABC",
            status: .qualified,
            lastContact: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            notes: "Cliente interesado en nuestros servicios premium",
            tags: ["VIP", "Premium"]
        )
        
        let client2 = Client(
            name: "María García",
            email: "maria.garcia@startup.com",
            phone: "+34 600 789 012",
            company: "StartupXYZ",
            status: .proposal,
            lastContact: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            notes: "Enviada propuesta comercial",
            tags: ["Startup", "Tech"]
        )
        
        let client3 = Client(
            name: "Carlos López",
            email: "carlos.lopez@corporacion.com",
            phone: "+34 600 345 678",
            company: "Corporación DEF",
            status: .prospect,
            lastContact: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            notes: "Primer contacto realizado",
            tags: ["Corporativo"]
        )
        
        clients = [client1, client2, client3]
        
        // Sample tasks
        let task1 = Task(
            title: "Llamar a Juan Pérez",
            description: "Seguimiento de propuesta enviada",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            priority: .high,
            status: .pending,
            clientId: client1.id
        )
        
        let task2 = Task(
            title: "Preparar presentación",
            description: "Crear presentación para María García",
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            priority: .medium,
            status: .inProgress,
            clientId: client2.id
        )
        
        let task3 = Task(
            title: "Enviar email de seguimiento",
            description: "Email de seguimiento a Carlos López",
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            priority: .low,
            status: .pending,
            clientId: client3.id
        )
        
        tasks = [task1, task2, task3]
        
        // Sample activities
        let activity1 = Activity(
            type: .call,
            title: "Llamada con Juan Pérez",
            description: "Discutimos los detalles de la propuesta",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            clientId: client1.id,
            duration: 1800 // 30 minutes
        )
        
        let activity2 = Activity(
            type: .email,
            title: "Email a María García",
            description: "Enviada propuesta comercial detallada",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            clientId: client2.id
        )
        
        let activity3 = Activity(
            type: .meeting,
            title: "Reunión con Carlos López",
            description: "Primera reunión de presentación",
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            clientId: client3.id,
            duration: 3600 // 1 hour
        )
        
        activities = [activity1, activity2, activity3]
    }
    
    // MARK: - Data Persistence (Placeholder)
    private func saveData() {
        // In a real app, you would save to Core Data, UserDefaults, or a database
        // For now, this is just a placeholder
    }
}
