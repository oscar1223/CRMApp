import SwiftUI

struct AddClientView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var company = ""
    @State private var status = ClientStatus.prospect
    @State private var notes = ""
    @State private var tags = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre completo", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Teléfono", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Información Empresarial")) {
                    TextField("Empresa", text: $company)
                    
                    Picker("Estado", selection: $status) {
                        ForEach(ClientStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section(header: Text("Notas y Etiquetas")) {
                    TextField("Notas", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Etiquetas (separadas por comas)", text: $tags)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Nuevo Cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveClient()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
    }
    
    private func saveClient() {
        let tagArray = tags.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let newClient = Client(
            name: name,
            email: email,
            phone: phone,
            company: company,
            status: status,
            lastContact: Date(),
            notes: notes,
            tags: tagArray
        )
        
        dataManager.addClient(newClient)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditClientView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var client: Client
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var company: String
    @State private var status: ClientStatus
    @State private var notes: String
    @State private var tags: String
    
    init(client: Binding<Client>) {
        self._client = client
        self._name = State(initialValue: client.wrappedValue.name)
        self._email = State(initialValue: client.wrappedValue.email)
        self._phone = State(initialValue: client.wrappedValue.phone)
        self._company = State(initialValue: client.wrappedValue.company)
        self._status = State(initialValue: client.wrappedValue.status)
        self._notes = State(initialValue: client.wrappedValue.notes)
        self._tags = State(initialValue: client.wrappedValue.tags.joined(separator: ", "))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre completo", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Teléfono", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Información Empresarial")) {
                    TextField("Empresa", text: $company)
                    
                    Picker("Estado", selection: $status) {
                        ForEach(ClientStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section(header: Text("Notas y Etiquetas")) {
                    TextField("Notas", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Etiquetas (separadas por comas)", text: $tags)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Editar Cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveClient()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
    }
    
    private func saveClient() {
        let tagArray = tags.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        client.name = name
        client.email = email
        client.phone = phone
        client.company = company
        client.status = status
        client.notes = notes
        client.tags = tagArray
        client.lastContact = Date()
        
        dataManager.updateClient(client)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddClientView()
        .environmentObject(DataManager())
}
