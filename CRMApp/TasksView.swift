import SwiftUI

struct TasksView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddTask = false
    @State private var searchText = ""
    @State private var selectedPriority: TaskPriority? = nil
    @State private var selectedStatus: TaskStatus? = nil
    
    var filteredTasks: [Task] {
        var tasks = dataManager.tasks
        
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText) ||
                task.assignedTo.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let priority = selectedPriority {
            tasks = tasks.filter { $0.priority == priority }
        }
        
        if let status = selectedStatus {
            tasks = tasks.filter { $0.status == status }
        }
        
        return tasks.sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "Todas",
                                isSelected: selectedPriority == nil && selectedStatus == nil,
                                action: { 
                                    selectedPriority = nil
                                    selectedStatus = nil
                                }
                            )
                            
                            // Priority Filters
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                FilterChip(
                                    title: priority.rawValue,
                                    isSelected: selectedPriority == priority,
                                    action: { 
                                        selectedPriority = selectedPriority == priority ? nil : priority
                                        selectedStatus = nil
                                    }
                                )
                            }
                            
                            // Status Filters
                            ForEach(TaskStatus.allCases, id: \.self) { status in
                                FilterChip(
                                    title: status.rawValue,
                                    isSelected: selectedStatus == status,
                                    action: { 
                                        selectedStatus = selectedStatus == status ? nil : status
                                        selectedPriority = nil
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Tasks List
                if filteredTasks.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        title: "No hay tareas",
                        message: searchText.isEmpty ? "Agrega tu primera tarea" : "No se encontraron tareas"
                    )
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                TaskRow(task: task)
                            }
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Tareas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            let task = filteredTasks[index]
            dataManager.deleteTask(task)
        }
    }
}

struct TaskRow: View {
    let task: Task
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority Indicator
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)
            
            // Task Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(task.assignedTo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(task.dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(isOverdue ? .red : .secondary)
                }
            }
            
            Spacer()
            
            // Status and Priority
            VStack(alignment: .trailing, spacing: 4) {
                Text(task.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
                
                Text(task.priority.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(priorityColor.opacity(0.2))
                    .foregroundColor(priorityColor)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    private var statusColor: Color {
        switch task.status {
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
    
    private var isOverdue: Bool {
        task.status != .completed && task.dueDate < Date()
    }
}

struct TaskDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var task: Task
    @State private var showingEditTask = false
    
    init(task: Task) {
        _task = State(initialValue: task)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(task.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Status and Priority
                    HStack(spacing: 12) {
                        Text(task.status.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(statusColor.opacity(0.2))
                            .foregroundColor(statusColor)
                            .cornerRadius(16)
                        
                        Text(task.priority.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(priorityColor.opacity(0.2))
                            .foregroundColor(priorityColor)
                            .cornerRadius(16)
                        
                        Spacer()
                    }
                    
                    // Task Details
                    VStack(spacing: 8) {
                        DetailRow(icon: "person", title: "Asignado a", value: task.assignedTo)
                        DetailRow(icon: "calendar", title: "Fecha límite", value: task.dueDate, style: .date)
                        DetailRow(icon: "clock", title: "Creado", value: task.createdAt, style: .date)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Client Info (if assigned)
                if let clientId = task.clientId,
                   let client = dataManager.clients.first(where: { $0.id == clientId }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cliente Asociado")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(client.name.prefix(1)))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(client.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(client.company)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Detalle Tarea")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") {
                    showingEditTask = true
                }
            }
        }
        .sheet(isPresented: $showingEditTask) {
            EditTaskView(task: $task)
        }
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    private var statusColor: Color {
        switch task.status {
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: Any
    let style: Date.FormatStyle?
    
    init(icon: String, title: String, value: String) {
        self.icon = icon
        self.title = title
        self.value = value
        self.style = nil
    }
    
    init(icon: String, title: String, value: Date, style: Date.FormatStyle) {
        self.icon = icon
        self.title = title
        self.value = value
        self.style = style
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let date = value as? Date, let style = style {
                Text(date, style: style)
                    .font(.subheadline)
                    .fontWeight(.medium)
            } else if let string = value as? String {
                Text(string)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}

#Preview {
    TasksView()
        .environmentObject(DataManager())
}
