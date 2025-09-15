import SwiftUI

// MARK: - Booking Settings Page
struct BookingSettingsPage: View {
    @StateObject private var store = BookingStore()
    @StateObject private var clientStore = ClientStore()
    @State private var newLinkTitle: String = ""
    @State private var newLinkURL: String = ""
    @State private var selectedBlackout: Date = Date()
    @State private var selectedBlackoutStart: Date = Date()
    @State private var selectedBlackoutEnd: Date = Date()
    @State private var showingEditModal = false
    @State private var editingLink: BookingLink?
    @State private var editLinkTitle: String = ""
    @State private var editLinkURL: String = ""
    @State private var showingClientModal = false
    @State private var editingClient: Client?
    @State private var newClientName: String = ""
    @State private var newClientEmail: String = ""
    @State private var newClientPhone: String = ""
    @State private var newClientNotes: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Tipos de Reserva")) {
                // Two-column layout for existing links
                if store.settings.links.count >= 2 {
                    HStack(spacing: 12) {
                        // First column
                        VStack(spacing: 8) {
                            BookingLinkCard(
                                link: store.settings.links[0],
                                onEdit: { editLink(store.settings.links[0]) },
                                onCopy: { copyLink(store.settings.links[0]) }
                            )
                        }
                        
                        // Second column
                        VStack(spacing: 8) {
                            BookingLinkCard(
                                link: store.settings.links[1],
                                onEdit: { editLink(store.settings.links[1]) },
                                onCopy: { copyLink(store.settings.links[1]) }
                            )
                        }
                    }
                } else if store.settings.links.count == 1 {
                    BookingLinkCard(
                        link: store.settings.links[0],
                        onEdit: { editLink(store.settings.links[0]) },
                        onCopy: { copyLink(store.settings.links[0]) }
                    )
                }
            }
            
            Section(header: Text("Añadir Nuevo Enlace")) {
                HStack {
                    TextField("Título", text: $newLinkTitle)
                    TextField("URL", text: $newLinkURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Añadir") { addLink() }.disabled(!canAddLink)
                }
            }
            
            Section(header: Text("Disponibilidad semanal")) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(1...7, id: \.self) { weekday in
                        dayRow(weekday)
                    }
                }
            }
            
            Section(header: Text("Estudio")) {
                TextField("Nombre del estudio", text: Binding(
                    get: { store.settings.studio.name },
                    set: { store.settings.studio.name = $0; store.save() }
                ))
                TextField("Ubicación", text: Binding(
                    get: { store.settings.studio.location },
                    set: { store.settings.studio.location = $0; store.save() }
                ))
            }
            
            Section(header: Text("Días no laborables")) {
                // Two-column layout for adding blackout dates
                HStack(alignment: .top, spacing: 16) {
                    // Left column - Single day option
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Añadir día individual")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        DatePicker("Seleccionar día", selection: $selectedBlackout, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                        
                        Button("Agregar día") { 
                            addBlackout(selectedBlackout) 
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    
                    // Right column - Date range option
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Añadir rango de días")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        DatePicker("Fecha inicio", selection: $selectedBlackoutStart, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                        
                        DatePicker("Fecha fin", selection: $selectedBlackoutEnd, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                        
                        Button("Agregar rango") { 
                            addBlackoutRange(selectedBlackoutStart, endDate: selectedBlackoutEnd) 
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .disabled(selectedBlackoutStart > selectedBlackoutEnd)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                }
                
                // List of existing blackout dates
                if !store.settings.blackoutDates.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Días no laborables actuales")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        ForEach(Array(groupedBlackouts().enumerated()), id: \.offset) { index, range in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(range.displayText)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    if !range.isSingleDay {
                                        Text("\(range.isos.count) días")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button("Eliminar") {
                                    removeBlackoutRange(range)
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text("Recordatorios")) {
                Toggle("Recordar 24h antes", isOn: Binding(
                    get: { store.settings.reminders24h },
                    set: { store.settings.reminders24h = $0; store.save() }
                ))
            }
            
            Section(header: Text("Clientes")) {
                // Add new client button
                Button("+ Añadir Cliente") {
                    newClientName = ""
                    newClientEmail = ""
                    newClientPhone = ""
                    newClientNotes = ""
                    editingClient = nil
                    showingClientModal = true
                }
                .foregroundColor(.accentColor)
                
                // Clients list
                if clientStore.clients.isEmpty {
                    Text("No hay clientes registrados")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(clientStore.clients) { client in
                        ClientRow(client: client) {
                            editingClient = client
                            newClientName = client.name
                            newClientEmail = client.email
                            newClientPhone = client.phone
                            newClientNotes = client.notes
                            showingClientModal = true
                        } onDelete: {
                            clientStore.deleteClient(client)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditModal) {
            EditBookingLinkModal(
                link: $editingLink,
                title: $editLinkTitle,
                url: $editLinkURL,
                onSave: saveEditedLink,
                onCancel: { showingEditModal = false }
            )
        }
        .sheet(isPresented: $showingClientModal) {
            ClientModal(
                client: $editingClient,
                name: $newClientName,
                email: $newClientEmail,
                phone: $newClientPhone,
                notes: $newClientNotes,
                onSave: saveClient,
                onCancel: { showingClientModal = false }
            )
        }
    }
    
    // MARK: - Helper Methods
    private func dayRow(_ weekday: Int) -> some View {
        let label = weekdaySymbol(weekday)
        let bindingEnabled = Binding(
            get: { store.settings.availability.days[weekday]?.enabled ?? false },
            set: { store.settings.availability.days[weekday]?.enabled = $0; store.save() }
        )
        let bindingStart = Binding(
            get: { store.settings.availability.days[weekday]?.start ?? Date() },
            set: { store.settings.availability.days[weekday]?.start = $0; store.save() }
        )
        let bindingEnd = Binding(
            get: { store.settings.availability.days[weekday]?.end ?? Date() },
            set: { store.settings.availability.days[weekday]?.end = $0; store.save() }
        )
        return HStack {
            Toggle(label, isOn: bindingEnabled)
            Spacer()
            DatePicker("", selection: bindingStart, displayedComponents: .hourAndMinute)
                .labelsHidden().frame(width: 110)
            Text("–")
            DatePicker("", selection: bindingEnd, displayedComponents: .hourAndMinute)
                .labelsHidden().frame(width: 110)
        }
    }
    
    private func weekdaySymbol(_ weekday: Int) -> String {
        var cal = Calendar.current
        cal.locale = Locale.current
        var symbols = cal.weekdaySymbols // starts Sunday=1
        let first = cal.firstWeekday
        // Map ISO 1..7 to system order
        let map = [1:2,2:3,3:4,4:5,5:6,6:7,7:1] // Mon->2 ... Sun->1
        let idx = (map[weekday] ?? 2) - 1
        // Rotate based on firstWeekday to match locale
        if first != 1 {
            let start = first - 1
            let rotated = Array(symbols[start...] + symbols[..<start])
            symbols = rotated
        }
        return symbols[idx]
    }
    
    private var canAddLink: Bool {
        guard let url = URL(string: newLinkURL), !newLinkTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func addLink() {
        guard canAddLink else { return }
        store.settings.links.append(BookingLink(title: newLinkTitle, url: newLinkURL))
        store.save()
        newLinkTitle = ""; newLinkURL = ""
    }
    
    private func addBlackout(_ date: Date) {
        let iso = isoDay(date)
        store.settings.blackoutDates.insert(iso)
        store.save()
    }
    
    private func addBlackoutRange(_ startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        var currentDate = startDate
        
        while currentDate <= endDate {
            let iso = isoDay(currentDate)
            store.settings.blackoutDates.insert(iso)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        store.save()
    }
    
    private func groupedBlackouts() -> [BlackoutRange] {
        let sortedDates = store.settings.blackoutDates.sorted()
        var ranges: [BlackoutRange] = []
        var currentRange: BlackoutRange?
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for iso in sortedDates {
            guard let date = dateFormatter.date(from: iso) else { continue }
            
            if let range = currentRange {
                let nextDay = calendar.date(byAdding: .day, value: 1, to: range.endDate) ?? range.endDate
                
                if calendar.isDate(date, inSameDayAs: nextDay) {
                    // Consecutive day, extend the range
                    currentRange = BlackoutRange(startDate: range.startDate, endDate: date, isos: range.isos + [iso])
                } else {
                    // Non-consecutive day, save current range and start new one
                    ranges.append(range)
                    currentRange = BlackoutRange(startDate: date, endDate: date, isos: [iso])
                }
            } else {
                // First date, start new range
                currentRange = BlackoutRange(startDate: date, endDate: date, isos: [iso])
            }
        }
        
        // Add the last range if it exists
        if let range = currentRange {
            ranges.append(range)
        }
        
        return ranges
    }
    
    private func removeBlackoutRange(_ range: BlackoutRange) {
        for iso in range.isos {
            store.settings.blackoutDates.remove(iso)
        }
        store.save()
    }
    
    private func isoDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    
    private func editLink(_ link: BookingLink) {
        editingLink = link
        editLinkTitle = link.title
        editLinkURL = link.url
        showingEditModal = true
    }
    
    private func copyLink(_ link: BookingLink) {
        UIPasteboard.general.string = link.url
    }
    
    private func saveEditedLink() {
        guard let link = editingLink,
              let index = store.settings.links.firstIndex(where: { $0.id == link.id }) else {
            showingEditModal = false
            return
        }
        
        store.settings.links[index] = BookingLink(
            id: link.id,
            title: editLinkTitle,
            url: editLinkURL
        )
        store.save()
        showingEditModal = false
    }
    
    private func saveClient() {
        if let client = editingClient {
            // Update existing client
            let updatedClient = Client(
                id: client.id,
                name: newClientName,
                email: newClientEmail,
                phone: newClientPhone,
                notes: newClientNotes
            )
            clientStore.updateClient(updatedClient)
        } else {
            // Add new client
            let newClient = Client(
                name: newClientName,
                email: newClientEmail,
                phone: newClientPhone,
                notes: newClientNotes
            )
            clientStore.addClient(newClient)
        }
        showingClientModal = false
    }
}
