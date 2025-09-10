import SwiftUI

struct ClientDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var client: Client
    @State private var showingEditClient = false
    @State private var showingAddActivity = false
    @State private var showingAddTask = false
    
    init(client: Client) {
        _client = State(initialValue: client)
    }
    
    var clientActivities: [Activity] {
        dataManager.activities.filter { $0.clientId == client.id }
            .sorted { $0.date > $1.date }
    }
    
    var clientTasks: [Task] {
        dataManager.tasks.filter { $0.clientId == client.id }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 16) {
                    // Avatar and Basic Info
                    VStack(spacing: 12) {
                        Circle()
                            .fill(statusColor.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(client.name.prefix(1)))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(statusColor)
                            )
                        
                        VStack(spacing: 4) {
                            Text(client.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(client.company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Status Badge
                    Text(client.status.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(20)
                    
                    // Contact Info
                    VStack(spacing: 8) {
                        ContactInfoRow(icon: "envelope", text: client.email)
                        ContactInfoRow(icon: "phone", text: client.phone)
                        ContactInfoRow(icon: "calendar", text: "Último contacto: \(client.lastContact, style: .date)")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Notes Section
                if !client.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notas")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(client.notes)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                // Tags Section
                if !client.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Etiquetas")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                            ForEach(client.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Tasks Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Tareas")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: { showingAddTask = true }) {
                            Image(systemName: "plus")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal)
                    
                    if clientTasks.isEmpty {
                        Text("No hay tareas asignadas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(clientTasks) { task in
                                TaskDetailRow(task: task)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Activities Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Actividades")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: { showingAddActivity = true }) {
                            Image(systemName: "plus")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal)
                    
                    if clientActivities.isEmpty {
                        Text("No hay actividades registradas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(clientActivities) { activity in
                                ActivityDetailRow(activity: activity)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Detalle Cliente")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") {
                    showingEditClient = true
                }
            }
        }
        .sheet(isPresented: $showingEditClient) {
            EditClientView(client: $client)
        }
        .sheet(isPresented: $showingAddActivity) {
            AddActivityView(clientId: client.id)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(clientId: client.id)
        }
    }
    
    private var statusColor: Color {
        switch client.status {
        case .prospect: return .blue
        case .lead: return .green
        case .qualified: return .orange
        case .proposal: return .purple
        case .negotiation: return .yellow
        case .closedWon: return .green
        case .closedLost: return .red
        }
    }
}

struct ContactInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct TaskDetailRow: View {
    let task: Task
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(task.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(task.priority.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(priorityColor.opacity(0.2))
                    .foregroundColor(priorityColor)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

struct ActivityDetailRow: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.type.icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(activity.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if let duration = activity.duration {
                    Text("Duración: \(Int(duration / 60)) min")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(activity.date, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        ClientDetailView(client: Client(
            name: "Juan Pérez",
            email: "juan.perez@empresa.com",
            phone: "+34 600 123 456",
            company: "Empresa ABC",
            status: .qualified,
            notes: "Cliente interesado en nuestros servicios premium",
            tags: ["VIP", "Premium"]
        ))
        .environmentObject(DataManager())
    }
}
