import SwiftUI
import SwiftData

// MARK: - Appointment Assignment View
struct AppointmentAssignmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appointments: [Appointment]
    @Query private var artists: [Artist]

    @State private var selectedStatus: AppointmentStatus? = nil
    @State private var selectedArtist: Artist? = nil
    @State private var showingNewAppointment = false
    @State private var selectedAppointment: Appointment? = nil
    @State private var searchText = ""

    private var filteredAppointments: [Appointment] {
        var result = appointments

        // Filter by status
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }

        // Filter by artist
        if let artist = selectedArtist {
            result = result.filter { $0.artistName == artist.name }
        }

        // Filter by search
        if !searchText.isEmpty {
            result = result.filter {
                $0.clientName.localizedCaseInsensitiveContains(searchText) ||
                $0.service.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.startDate > $1.startDate }
    }

    private var upcomingAppointments: [Appointment] {
        filteredAppointments.filter { $0.startDate > Date() && $0.status != .cancelled }
    }

    private var pendingAppointments: [Appointment] {
        filteredAppointments.filter { $0.status == .pending }
    }

    var body: some View {
        ZStack {
            Color.clear.studioBackground()

            VStack(spacing: 0) {
                headerSection
                filtersSection
                searchBar

                if filteredAppointments.isEmpty {
                    emptyState
                } else {
                    appointmentsList
                }
            }
        }
        .sheet(isPresented: $showingNewAppointment) {
            NewAppointmentSheet(modelContext: modelContext, artists: artists)
        }
        .sheet(item: $selectedAppointment) { appointment in
            AppointmentDetailSheet(appointment: appointment, modelContext: modelContext, artists: artists)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Citas")
                    .modernText(size: UIDevice.isIPad ? .title : .headline, color: .textPrimary)
                    .fontWeight(.bold)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 8, height: 8)
                        Text("\(upcomingAppointments.count) próximas")
                            .modernText(size: .caption, color: .textSecondary)
                    }

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.warningOrange)
                            .frame(width: 8, height: 8)
                        Text("\(pendingAppointments.count) pendientes")
                            .modernText(size: .caption, color: .textSecondary)
                    }
                }
            }

            Spacer()

            Button(action: { showingNewAppointment = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: UIDevice.isIPad ? 14 : 12, weight: .semibold))
                    Text("Nueva")
                        .font(.system(size: UIDevice.isIPad ? 14 : 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, UIDevice.isIPad ? 16 : 12)
                .padding(.vertical, UIDevice.isIPad ? 10 : 8)
                .background(
                    RoundedRectangle(cornerRadius: UIDevice.isIPad ? 12 : 10, style: .continuous)
                        .fill(Color.brandPrimary)
                )
                .shadow(color: Color.brandPrimary.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
        .modernPadding(.horizontal, .medium)
        .modernPadding(.top, .large)
    }

    // MARK: - Filters
    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Status filters
                FilterChip(
                    title: "Todas",
                    isSelected: selectedStatus == nil,
                    action: { selectedStatus = nil }
                )

                ForEach([AppointmentStatus.pending, .confirmed, .inProgress, .completed, .cancelled], id: \.self) { status in
                    FilterChip(
                        title: status.displayName,
                        isSelected: selectedStatus == status,
                        color: status.colorValue,
                        action: { selectedStatus = status }
                    )
                }

                Divider()
                    .frame(height: 24)
                    .padding(.horizontal, 4)

                // Artist filters
                FilterChip(
                    title: "Todos los artistas",
                    isSelected: selectedArtist == nil,
                    action: { selectedArtist = nil }
                )

                ForEach(artists.filter { $0.status == .active }) { artist in
                    FilterChip(
                        title: artist.name,
                        isSelected: selectedArtist?.id == artist.id,
                        action: { selectedArtist = artist }
                    )
                }
            }
            .modernPadding(.horizontal, .medium)
        }
        .modernPadding(.top, .medium)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        SearchBar(text: $searchText, placeholder: "Buscar citas...")
            .modernPadding(.horizontal, .medium)
            .modernPadding(.top, .medium)
    }

    // MARK: - Appointments List
    private var appointmentsList: some View {
        ScrollView {
            LazyVStack(spacing: UIDevice.isIPad ? 12 : 10) {
                ForEach(filteredAppointments) { appointment in
                    AppointmentRow(appointment: appointment)
                        .onTapGesture {
                            selectedAppointment = appointment
                        }
                }
            }
            .modernPadding(.horizontal, .medium)
            .modernPadding(.top, .medium)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        EmptyStateView(
            icon: searchText.isEmpty ? "calendar.badge.clock" : "magnifyingglass",
            title: searchText.isEmpty ? "No hay citas" : "Sin resultados",
            message: searchText.isEmpty ? "Crea tu primera cita para comenzar" : "No se encontraron citas",
            actionTitle: searchText.isEmpty ? "Crear primera cita" : nil,
            action: searchText.isEmpty ? { showingNewAppointment = true } : nil
        )
    }
}

// MARK: - Appointment Row
private struct AppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: UIDevice.isIPad ? 16 : 12) {
            // Date indicator
            VStack(spacing: 4) {
                Text(appointment.startDate.formatted(.dateTime.day()))
                    .font(.system(size: UIDevice.isIPad ? 24 : 20, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(appointment.startDate.formatted(.dateTime.month(.abbreviated)))
                    .font(.system(size: UIDevice.isIPad ? 12 : 10, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            .frame(width: UIDevice.isIPad ? 60 : 50)

            // Content
            VStack(alignment: .leading, spacing: UIDevice.isIPad ? 6 : 4) {
                Text(appointment.clientName)
                    .modernText(size: UIDevice.isIPad ? .body : .subhead, color: .textPrimary)
                    .fontWeight(.semibold)

                Text(appointment.service)
                    .modernText(size: UIDevice.isIPad ? .subhead : .caption, color: .textSecondary)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(appointment.timeRange)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.textTertiary)

                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 10))
                        Text(appointment.artistName)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundColor(.brandPrimary)
                }
            }

            Spacer()

            // Status and price
            VStack(alignment: .trailing, spacing: 8) {
                StatusBadge(
                    text: appointment.status.displayName,
                    color: appointment.status.colorValue,
                    icon: appointment.status.icon
                )

                Text(String(format: "%.0f€", appointment.price))
                    .font(.system(size: UIDevice.isIPad ? 16 : 14, weight: .bold))
                    .foregroundColor(.textPrimary)
            }
        }
        .modernPadding(.all, .medium)
        .background(
            RoundedRectangle(cornerRadius: UIDevice.isIPad ? 16 : 14, style: .continuous)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: UIDevice.isIPad ? 16 : 14, style: .continuous)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

// MARK: - New Appointment Sheet
private struct NewAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    let artists: [Artist]

    @State private var clientName = ""
    @State private var clientEmail = ""
    @State private var clientPhone = ""
    @State private var selectedArtist: Artist?
    @State private var startDate = Date()
    @State private var duration: Double = 2.0
    @State private var service = ""
    @State private var price: String = ""
    @State private var deposit: String = ""
    @State private var notes = ""

    private var isValid: Bool {
        !clientName.isEmpty && selectedArtist != nil && !service.isEmpty
    }

    private var endDate: Date {
        startDate.addingTimeInterval(duration * 3600)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Client info
                    FormSection(title: "Cliente") {
                        FormField(title: "Nombre", text: $clientName, placeholder: "Nombre del cliente")
                        FormField(title: "Email", text: $clientEmail, placeholder: "email@ejemplo.com")
                        FormField(title: "Teléfono", text: $clientPhone, placeholder: "+34 600 000 000")
                    }

                    // Appointment details
                    FormSection(title: "Detalles de la Cita") {
                        // Artist picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Artista")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textSecondary)

                            Menu {
                                ForEach(artists.filter { $0.status == .active }) { artist in
                                    Button(action: { selectedArtist = artist }) {
                                        Text(artist.name)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedArtist?.name ?? "Seleccionar artista")
                                        .foregroundColor(selectedArtist == nil ? .textTertiary : .textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.textTertiary)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color.borderSecondary, lineWidth: 0.5)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        // Date picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha y Hora")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textSecondary)

                            DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                        }
                        .padding(.horizontal, 16)

                        // Duration
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Duración")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                Spacer()
                                Text("\(Int(duration))h")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.brandPrimary)
                            }

                            Slider(value: $duration, in: 0.5...8, step: 0.5)
                                .tint(.brandPrimary)
                        }
                        .padding(.horizontal, 16)

                        FormField(title: "Servicio", text: $service, placeholder: "Ej: Tatuaje Brazo - Realismo")
                    }

                    // Pricing
                    FormSection(title: "Precio") {
                        FormField(title: "Precio (€)", text: $price, placeholder: "0")
                        FormField(title: "Depósito (€)", text: $deposit, placeholder: "0")
                    }

                    // Notes
                    FormSection(title: "Notas") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notas adicionales")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textSecondary)

                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color.borderSecondary, lineWidth: 0.5)
                                        )
                                )
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Nueva Cita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveAppointment()
                    }
                    .foregroundColor(isValid ? .brandPrimary : .textTertiary)
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveAppointment() {
        let newAppointment = Appointment(
            clientName: clientName,
            clientEmail: clientEmail,
            clientPhone: clientPhone,
            artistId: selectedArtist?.id,
            artistName: selectedArtist?.name ?? "",
            startDate: startDate,
            endDate: endDate,
            service: service,
            status: .pending,
            price: Double(price) ?? 0,
            deposit: Double(deposit) ?? 0,
            notes: notes
        )

        modelContext.insert(newAppointment)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Appointment Detail Sheet
private struct AppointmentDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let appointment: Appointment
    let modelContext: ModelContext
    let artists: [Artist]

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingStatusMenu = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    appointmentHeader

                    // Client info
                    clientSection

                    // Appointment details
                    detailsSection

                    // Status actions
                    statusActionsSection

                    // Other actions
                    actionsSection

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditAppointmentSheet(appointment: appointment, modelContext: modelContext, artists: artists)
        }
        .alert("Eliminar Cita", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                deleteAppointment()
            }
        } message: {
            Text("¿Estás seguro de eliminar esta cita? Esta acción no se puede deshacer.")
        }
    }

    private var appointmentHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [appointment.status.colorValue, appointment.status.colorValue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: appointment.status.icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
            }
            .shadow(color: appointment.status.colorValue.opacity(0.3), radius: 20, x: 0, y: 10)

            VStack(spacing: 8) {
                Text(appointment.clientName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(appointment.service)
                    .modernText(size: .body, color: .textSecondary)
                    .multilineTextAlignment(.center)

                StatusBadge(
                    text: appointment.status.displayName,
                    color: appointment.status.colorValue,
                    icon: appointment.status.icon
                )
            }
        }
    }

    private var clientSection: some View {
        VStack(spacing: 12) {
            InfoRow(icon: "envelope.fill", title: "Email", value: appointment.clientEmail)
            if !appointment.clientPhone.isEmpty {
                Divider().padding(.leading, 52)
                InfoRow(icon: "phone.fill", title: "Teléfono", value: appointment.clientPhone)
            }
        }
        .padding(16)
        .modernCard()
        .padding(.horizontal, 16)
    }

    private var detailsSection: some View {
        VStack(spacing: 12) {
            InfoRow(
                icon: "calendar",
                title: "Fecha",
                value: appointment.startDate.formatted(date: .long, time: .omitted)
            )
            Divider().padding(.leading, 52)
            InfoRow(icon: "clock", title: "Hora", value: appointment.timeRange)
            Divider().padding(.leading, 52)
            InfoRow(icon: "person.fill", title: "Artista", value: appointment.artistName)
            Divider().padding(.leading, 52)
            InfoRow(icon: "eurosign.circle", title: "Precio", value: String(format: "%.0f€", appointment.price))
            if appointment.deposit > 0 {
                Divider().padding(.leading, 52)
                InfoRow(icon: "creditcard", title: "Depósito", value: String(format: "%.0f€", appointment.deposit))
            }
            if !appointment.notes.isEmpty {
                Divider().padding(.leading, 52)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.backgroundTertiary)
                                .frame(width: 40, height: 40)
                            Image(systemName: "note.text")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.brandPrimary)
                        }
                        Text("Notas")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    Text(appointment.notes)
                        .font(.system(size: 15))
                        .foregroundColor(.textPrimary)
                        .padding(.leading, 52)
                }
            }
        }
        .padding(16)
        .modernCard()
        .padding(.horizontal, 16)
    }

    private var statusActionsSection: some View {
        VStack(spacing: 12) {
            Text("Cambiar estado")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

            HStack(spacing: 8) {
                if appointment.status == .pending {
                    statusButton("Confirmar", icon: "checkmark.circle.fill", color: .brandPrimary) {
                        updateStatus(.confirmed)
                    }
                }

                if appointment.status == .confirmed {
                    statusButton("Iniciar", icon: "play.circle.fill", color: .calendarEventBlue) {
                        updateStatus(.inProgress)
                    }
                }

                if appointment.status == .inProgress {
                    statusButton("Completar", icon: "checkmark.seal.fill", color: .successGreen) {
                        updateStatus(.completed)
                    }
                }

                if appointment.status != .cancelled && appointment.status != .completed {
                    statusButton("Cancelar", icon: "xmark.circle.fill", color: .errorRed) {
                        updateStatus(.cancelled)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func statusButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: { showingEditSheet = true }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Editar cita")
                }
            }
            .modernButton(style: .primary)
            .padding(.horizontal, 16)

            Button(action: { showingDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Eliminar cita")
                }
                .foregroundColor(.errorRed)
            }
            .modernButton(style: .secondary)
            .padding(.horizontal, 16)
        }
    }

    private func updateStatus(_ newStatus: AppointmentStatus) {
        appointment.status = newStatus
        appointment.updatedAt = Date()
        try? modelContext.save()
    }

    private func deleteAppointment() {
        modelContext.delete(appointment)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Edit Appointment Sheet
private struct EditAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let appointment: Appointment
    let modelContext: ModelContext
    let artists: [Artist]

    @State private var clientName: String
    @State private var clientEmail: String
    @State private var clientPhone: String
    @State private var selectedArtist: Artist?
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var service: String
    @State private var price: String
    @State private var deposit: String
    @State private var notes: String

    init(appointment: Appointment, modelContext: ModelContext, artists: [Artist]) {
        self.appointment = appointment
        self.modelContext = modelContext
        self.artists = artists
        _clientName = State(initialValue: appointment.clientName)
        _clientEmail = State(initialValue: appointment.clientEmail)
        _clientPhone = State(initialValue: appointment.clientPhone)
        _selectedArtist = State(initialValue: artists.first { $0.name == appointment.artistName })
        _startDate = State(initialValue: appointment.startDate)
        _endDate = State(initialValue: appointment.endDate)
        _service = State(initialValue: appointment.service)
        _price = State(initialValue: String(format: "%.0f", appointment.price))
        _deposit = State(initialValue: String(format: "%.0f", appointment.deposit))
        _notes = State(initialValue: appointment.notes)
    }

    private var isValid: Bool {
        !clientName.isEmpty && selectedArtist != nil && !service.isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    FormSection(title: "Cliente") {
                        FormField(title: "Nombre", text: $clientName, placeholder: "Nombre del cliente")
                        FormField(title: "Email", text: $clientEmail, placeholder: "email@ejemplo.com")
                        FormField(title: "Teléfono", text: $clientPhone, placeholder: "+34 600 000 000")
                    }

                    FormSection(title: "Detalles") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Artista")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textSecondary)

                            Menu {
                                ForEach(artists.filter { $0.status == .active }) { artist in
                                    Button(action: { selectedArtist = artist }) {
                                        Text(artist.name)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedArtist?.name ?? "Seleccionar artista")
                                        .foregroundColor(selectedArtist == nil ? .textTertiary : .textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.textTertiary)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color.borderSecondary, lineWidth: 0.5)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        FormField(title: "Servicio", text: $service, placeholder: "Descripción del servicio")
                    }

                    FormSection(title: "Precio") {
                        FormField(title: "Precio (€)", text: $price, placeholder: "0")
                        FormField(title: "Depósito (€)", text: $deposit, placeholder: "0")
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Editar Cita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveChanges()
                    }
                    .foregroundColor(isValid ? .brandPrimary : .textTertiary)
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveChanges() {
        appointment.clientName = clientName
        appointment.clientEmail = clientEmail
        appointment.clientPhone = clientPhone
        appointment.artistId = selectedArtist?.id
        appointment.artistName = selectedArtist?.name ?? ""
        appointment.service = service
        appointment.price = Double(price) ?? 0
        appointment.deposit = Double(deposit) ?? 0
        appointment.notes = notes
        appointment.updatedAt = Date()

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AppointmentAssignmentView()
        .modelContainer(for: [Appointment.self, Artist.self], inMemory: true)
}
