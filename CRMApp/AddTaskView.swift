import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var priority = TaskPriority.medium
    @State private var status = TaskStatus.pending
    @State private var assignedTo = "Yo"
    @State private var selectedClient: Client? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información de la Tarea")) {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Configuración")) {
                    DatePicker("Fecha límite", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Prioridad", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Picker("Estado", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    TextField("Asignado a", text: $assignedTo)
                }
                
                Section(header: Text("Cliente (Opcional)")) {
                    Picker("Cliente", selection: $selectedClient) {
                        Text("Sin cliente").tag(nil as Client?)
                        ForEach(dataManager.clients) { client in
                            Text("\(client.name) - \(client.company)").tag(client as Client?)
                        }
                    }
                }
            }
            .navigationTitle("Nueva Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        let newTask = Task(
            title: title,
            description: description,
            dueDate: dueDate,
            priority: priority,
            status: status,
            clientId: selectedClient?.id,
            assignedTo: assignedTo
        )
        
        dataManager.addTask(newTask)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditTaskView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var task: Task
    
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var priority: TaskPriority
    @State private var status: TaskStatus
    @State private var assignedTo: String
    @State private var selectedClient: Client?
    
    init(task: Binding<Task>) {
        self._task = task
        self._title = State(initialValue: task.wrappedValue.title)
        self._description = State(initialValue: task.wrappedValue.description)
        self._dueDate = State(initialValue: task.wrappedValue.dueDate)
        self._priority = State(initialValue: task.wrappedValue.priority)
        self._status = State(initialValue: task.wrappedValue.status)
        self._assignedTo = State(initialValue: task.wrappedValue.assignedTo)
        self._selectedClient = State(initialValue: nil)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información de la Tarea")) {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Configuración")) {
                    DatePicker("Fecha límite", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Prioridad", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Picker("Estado", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    TextField("Asignado a", text: $assignedTo)
                }
                
                Section(header: Text("Cliente (Opcional)")) {
                    Picker("Cliente", selection: $selectedClient) {
                        Text("Sin cliente").tag(nil as Client?)
                        ForEach(dataManager.clients) { client in
                            Text("\(client.name) - \(client.company)").tag(client as Client?)
                        }
                    }
                }
            }
            .navigationTitle("Editar Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let clientId = task.clientId {
                    selectedClient = dataManager.clients.first { $0.id == clientId }
                }
            }
        }
    }
    
    private func saveTask() {
        task.title = title
        task.description = description
        task.dueDate = dueDate
        task.priority = priority
        task.status = status
        task.assignedTo = assignedTo
        task.clientId = selectedClient?.id
        
        dataManager.updateTask(task)
        presentationMode.wrappedValue.dismiss()
    }
}

// Convenience initializer for AddTaskView with clientId
extension AddTaskView {
    init(clientId: UUID?) {
        self.init()
        if let clientId = clientId {
            self._selectedClient = State(initialValue: nil)
        }
    }
}

#Preview {
    AddTaskView()
        .environmentObject(DataManager())
}
