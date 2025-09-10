import SwiftUI

struct AddActivityView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var type = ActivityType.call
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var duration: TimeInterval? = nil
    @State private var selectedClient: Client? = nil
    @State private var hasDuration = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tipo de Actividad")) {
                    Picker("Tipo", selection: $type) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Información")) {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    DatePicker("Fecha y hora", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Duración (Opcional)")) {
                    Toggle("Tiene duración", isOn: $hasDuration)
                    
                    if hasDuration {
                        HStack {
                            Text("Duración")
                            Spacer()
                            TextField("Minutos", value: Binding(
                                get: { duration != nil ? Int(duration! / 60) : nil },
                                set: { duration = $0 != nil ? TimeInterval($0! * 60) : nil }
                            ), format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("min")
                                .foregroundColor(.secondary)
                        }
                    }
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
            .navigationTitle("Nueva Actividad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveActivity()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveActivity() {
        let newActivity = Activity(
            type: type,
            title: title,
            description: description,
            date: date,
            clientId: selectedClient?.id,
            duration: hasDuration ? duration : nil
        )
        
        dataManager.addActivity(newActivity)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditActivityView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var activity: Activity
    
    @State private var type: ActivityType
    @State private var title: String
    @State private var description: String
    @State private var date: Date
    @State private var duration: TimeInterval?
    @State private var selectedClient: Client?
    @State private var hasDuration: Bool
    
    init(activity: Binding<Activity>) {
        self._activity = activity
        self._type = State(initialValue: activity.wrappedValue.type)
        self._title = State(initialValue: activity.wrappedValue.title)
        self._description = State(initialValue: activity.wrappedValue.description)
        self._date = State(initialValue: activity.wrappedValue.date)
        self._duration = State(initialValue: activity.wrappedValue.duration)
        self._hasDuration = State(initialValue: activity.wrappedValue.duration != nil)
        self._selectedClient = State(initialValue: nil)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tipo de Actividad")) {
                    Picker("Tipo", selection: $type) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Información")) {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    DatePicker("Fecha y hora", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Duración (Opcional)")) {
                    Toggle("Tiene duración", isOn: $hasDuration)
                    
                    if hasDuration {
                        HStack {
                            Text("Duración")
                            Spacer()
                            TextField("Minutos", value: Binding(
                                get: { duration != nil ? Int(duration! / 60) : nil },
                                set: { duration = $0 != nil ? TimeInterval($0! * 60) : nil }
                            ), format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("min")
                                .foregroundColor(.secondary)
                        }
                    }
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
            .navigationTitle("Editar Actividad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveActivity()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let clientId = activity.clientId {
                    selectedClient = dataManager.clients.first { $0.id == clientId }
                }
            }
        }
    }
    
    private func saveActivity() {
        activity.type = type
        activity.title = title
        activity.description = description
        activity.date = date
        activity.duration = hasDuration ? duration : nil
        activity.clientId = selectedClient?.id
        
        dataManager.updateActivity(activity)
        presentationMode.wrappedValue.dismiss()
    }
}

// Convenience initializer for AddActivityView with clientId
extension AddActivityView {
    init(clientId: UUID?) {
        self.init()
        if let clientId = clientId {
            self._selectedClient = State(initialValue: nil)
        }
    }
}

#Preview {
    AddActivityView()
        .environmentObject(DataManager())
}
