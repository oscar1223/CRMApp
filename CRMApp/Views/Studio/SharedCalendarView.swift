import SwiftUI
import SwiftData

// MARK: - Shared Calendar View
struct SharedCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appointments: [Appointment]
    @Query private var artists: [Artist]

    @State private var selectedDate = Date()
    @State private var selectedArtist: Artist? = nil
    @State private var viewMode: CalendarViewMode = .day
    @State private var showingNewAppointment = false

    private var filteredAppointments: [Appointment] {
        let calendar = Calendar.current
        var result = appointments.filter {
            calendar.isDate($0.startDate, inSameDayAs: selectedDate)
        }

        if let artist = selectedArtist {
            result = result.filter { $0.artistName == artist.name }
        }

        return result.sorted { $0.startDate < $1.startDate }
    }

    var body: some View {
        ZStack {
            Color.clear.studioBackground()

            VStack(spacing: 0) {
                headerSection
                viewModeToggle
                artistFilter
                calendarView
                appointmentsTimelineSection
            }
        }
        .sheet(isPresented: $showingNewAppointment) {
            NewQuickAppointmentSheet(
                modelContext: modelContext,
                artists: artists,
                selectedDate: selectedDate,
                selectedArtist: selectedArtist
            )
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Calendario Compartido")
                    .modernText(size: UIDevice.isIPad ? .title : .headline, color: .textPrimary)
                    .fontWeight(.bold)

                Text(selectedDate.formatted(date: .complete, time: .omitted))
                    .modernText(size: UIDevice.isIPad ? .subhead : .caption, color: .textSecondary)
            }

            Spacer()

            Button(action: { showingNewAppointment = true }) {
                Image(systemName: "plus")
                    .font(.system(size: UIDevice.isIPad ? 14 : 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(UIDevice.isIPad ? 12 : 10)
                    .background(
                        Circle()
                            .fill(Color.brandPrimary)
                    )
                    .shadow(color: Color.brandPrimary.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
        .modernPadding(.horizontal, .medium)
        .modernPadding(.top, .large)
    }

    // MARK: - View Mode Toggle
    private var viewModeToggle: some View {
        HStack(spacing: 0) {
            ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(viewMode == mode ? .white : .textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewMode == mode ? Color.brandPrimary : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
        .frame(maxWidth: 280)
        .modernPadding(.horizontal, .medium)
        .modernPadding(.top, .medium)
    }

    // MARK: - Artist Filter
    private var artistFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "Todos",
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

    // MARK: - Calendar View
    private var calendarView: some View {
        VStack(spacing: 12) {
            // Month/Year header
            HStack {
                Button(action: previousPeriod) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.brandPrimary)
                }

                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)

                Button(action: nextPeriod) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.brandPrimary)
                }
            }
            .padding(.horizontal, 16)

            // Week days
            weekDaysHeader

            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: UIDevice.isIPad ? 56 : 48)
                    }
                }
            }
        }
        .padding(16)
        .modernCard()
        .modernPadding(.horizontal, .medium)
        .modernPadding(.top, .medium)
    }

    private var weekDaysHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekDaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(date)
        let appointmentCount = appointments.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: date)
        }.count

        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDate = date
            }
        }) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: UIDevice.isIPad ? 16 : 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : (isToday ? .brandPrimary : .textPrimary))

                if appointmentCount > 0 {
                    Circle()
                        .fill(isSelected ? .white : .brandPrimary)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIDevice.isIPad ? 56 : 48)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.brandPrimary : (isToday ? Color.brandPrimary.opacity(0.1) : Color.clear))
            )
        }
    }

    // MARK: - Appointments Timeline
    private var appointmentsTimelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Citas del día")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(filteredAppointments.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.brandPrimary.opacity(0.1))
                    )
            }
            .padding(.horizontal, 16)

            if filteredAppointments.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.clock",
                    title: "No hay citas",
                    message: "No hay citas programadas para este día"
                )
                .frame(height: 150)
            } else {
                appointmentTimeline
            }
        }
        .modernPadding(.top, .medium)
    }

    private var appointmentTimeline: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredAppointments) { appointment in
                    TimelineAppointmentRow(appointment: appointment)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Helper Properties
    private var weekDaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.veryShortWeekdaySymbols.map { String($0.prefix(1)) }
    }

    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let monthStart = calendar.date(from: components),
              let monthRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let paddingDays = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: paddingDays)

        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }

        return days
    }

    private func previousPeriod() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        }
    }

    private func nextPeriod() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        }
    }
}

// MARK: - Supporting Types
enum CalendarViewMode: String, CaseIterable {
    case day = "Día"
    case week = "Semana"
    case month = "Mes"
}

// MARK: - Timeline Appointment Row
private struct TimelineAppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(spacing: 2) {
                Text(appointment.startDate.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.textPrimary)

                Rectangle()
                    .fill(appointment.status.colorValue)
                    .frame(width: 3, height: 40)

                Text(appointment.endDate.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            .frame(width: 60)

            // Appointment details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(appointment.clientName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    Spacer()

                    StatusBadge(
                        text: appointment.status.displayName,
                        color: appointment.status.colorValue,
                        icon: appointment.status.icon
                    )
                }

                Text(appointment.service)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 9))
                        Text(appointment.artistName)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.brandPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: "eurosign.circle")
                            .font(.system(size: 9))
                        Text(String(format: "%.0f€", appointment.price))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.textTertiary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(appointment.status.colorValue.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Quick Appointment Sheet
private struct NewQuickAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    let artists: [Artist]
    let selectedDate: Date
    let selectedArtist: Artist?

    @State private var clientName = ""
    @State private var service = ""
    @State private var selectedArtistLocal: Artist?
    @State private var startTime = Date()
    @State private var duration: Double = 1.0

    init(modelContext: ModelContext, artists: [Artist], selectedDate: Date, selectedArtist: Artist?) {
        self.modelContext = modelContext
        self.artists = artists
        self.selectedDate = selectedDate
        self.selectedArtist = selectedArtist
        _selectedArtistLocal = State(initialValue: selectedArtist)

        // Set start time to selected date at current hour
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        _startTime = State(initialValue: calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate) ?? selectedDate)
    }

    private var isValid: Bool {
        !clientName.isEmpty && !service.isEmpty && selectedArtistLocal != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Cliente") {
                    TextField("Nombre", text: $clientName)
                    TextField("Servicio", text: $service)
                }

                Section("Detalles") {
                    Picker("Artista", selection: $selectedArtistLocal) {
                        Text("Seleccionar").tag(nil as Artist?)
                        ForEach(artists.filter { $0.status == .active }) { artist in
                            Text(artist.name).tag(artist as Artist?)
                        }
                    }

                    DatePicker("Hora", selection: $startTime, displayedComponents: .hourAndMinute)

                    VStack {
                        HStack {
                            Text("Duración")
                            Spacer()
                            Text("\(Int(duration))h")
                                .foregroundColor(.brandPrimary)
                        }
                        Slider(value: $duration, in: 0.5...8, step: 0.5)
                            .tint(.brandPrimary)
                    }
                }
            }
            .navigationTitle("Nueva Cita Rápida")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveAppointment()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveAppointment() {
        let endTime = startTime.addingTimeInterval(duration * 3600)

        let appointment = Appointment(
            clientName: clientName,
            clientEmail: "",
            clientPhone: "",
            artistId: selectedArtistLocal?.id,
            artistName: selectedArtistLocal?.name ?? "",
            startDate: startTime,
            endDate: endTime,
            service: service,
            status: .confirmed
        )

        modelContext.insert(appointment)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    SharedCalendarView()
        .modelContainer(for: [Appointment.self, Artist.self], inMemory: true)
}
