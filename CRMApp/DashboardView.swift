import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dashboard CRM")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Resumen de tu gestión comercial")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Metrics Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        MetricCard(
                            title: "Total Clientes",
                            value: "\(dataManager.dashboardMetrics.totalClients)",
                            icon: "person.2.fill",
                            color: .blue
                        )
                        
                        MetricCard(
                            title: "Nuevos Leads",
                            value: "\(dataManager.dashboardMetrics.newLeads)",
                            icon: "person.badge.plus",
                            color: .green
                        )
                        
                        MetricCard(
                            title: "Tareas Pendientes",
                            value: "\(dataManager.dashboardMetrics.pendingTasks)",
                            icon: "checklist",
                            color: .orange
                        )
                        
                        MetricCard(
                            title: "Deals Cerrados",
                            value: "\(dataManager.dashboardMetrics.closedDeals)",
                            icon: "checkmark.circle.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Revenue Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            Text("Ingresos")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Text("€\(String(format: "%.0f", dataManager.dashboardMetrics.revenue))")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Recent Activities
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Actividades Recientes")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(dataManager.activities.prefix(5)) { activity in
                                ActivityRow(activity: activity)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Pending Tasks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tareas Pendientes")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(dataManager.tasks.filter { $0.status == .pending }.prefix(3)) { task in
                                TaskRow(task: task)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
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

struct TaskRow: View {
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
                    .lineLimit(1)
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

#Preview {
    DashboardView()
        .environmentObject(DataManager())
}
