import SwiftUI
import SwiftData

// MARK: - Studio Dashboard View (Refactored)
struct StudioDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appointments: [Appointment]
    @Query private var artists: [Artist]

    @State private var selectedView: DashboardView? = nil

    // MARK: - Computed Stats
    private var todayAppointments: [Appointment] {
        appointments.filter { Calendar.current.isDateInToday($0.startDate) }
    }

    private var upcomingAppointments: [Appointment] {
        appointments.filter {
            $0.startDate > Date() && $0.status != .cancelled
        }.sorted { $0.startDate < $1.startDate }
    }

    private var pendingAppointments: [Appointment] {
        appointments.filter { $0.status == .pending }
    }

    private var activeArtists: [Artist] {
        artists.filter { $0.status == .active }
    }

    private var monthRevenue: Double {
        let calendar = Calendar.current
        return appointments
            .filter {
                calendar.isDate($0.startDate, equalTo: Date(), toGranularity: .month) &&
                $0.status == .completed
            }
            .reduce(0) { $0 + $1.price }
    }

    var body: some View {
        ZStack {
            Color.clear.studioBackground()

            ScrollView {
                VStack(spacing: UIDevice.isIPad ? 24 : 20) {
                    headerSection
                    quickStatsSection
                    quickActionsGrid
                    todayScheduleSection
                    upcomingAppointmentsSection

                    Spacer(minLength: UIDevice.isIPad ? 60 : 40)
                }
                .modernPadding(.horizontal, .medium)
                .modernPadding(.top, .large)
            }
        }
        .sheet(item: $selectedView) { view in
            viewSheet(for: view)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: UIDevice.isIPad ? 12 : 8) {
            HStack {
                Image(systemName: "building.2.fill")
                    .font(.system(size: UIDevice.isIPad ? 32 : 28, weight: .semibold))
                    .foregroundColor(.brandPrimary)

                Spacer()

                Text(Date().formatted(.dateTime.hour().minute()))
                    .font(.system(size: UIDevice.isIPad ? 20 : 18, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Gestión de Estudio")
                    .modernText(size: UIDevice.isIPad ? .title : .headline, color: .textPrimary)
                    .fontWeight(.bold)

                Text("Visión general de tu negocio")
                    .modernText(size: UIDevice.isIPad ? .body : .subhead, color: .textSecondary)
            }
        }
    }

    // MARK: - Quick Stats
    private var quickStatsSection: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: UIDevice.isIPad ? 4 : 2),
            spacing: 12
        ) {
            StatCard(
                icon: "eurosign.circle.fill",
                title: "Este mes",
                value: String(format: "%.0f€", monthRevenue),
                color: .successGreen,
                style: .mini
            )

            StatCard(
                icon: "person.3.fill",
                title: "Artistas",
                value: "\(activeArtists.count)",
                color: .brandPrimary,
                style: .mini
            )

            StatCard(
                icon: "calendar.circle.fill",
                title: "Hoy",
                value: "\(todayAppointments.count)",
                color: .calendarEventBlue,
                style: .mini
            )

            StatCard(
                icon: "clock.fill",
                title: "Pendientes",
                value: "\(pendingAppointments.count)",
                color: .warningOrange,
                style: .mini
            )
        }
    }

    // MARK: - Quick Actions Grid
    private var quickActionsGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
            spacing: 12
        ) {
            QuickActionCard(
                icon: "person.3.fill",
                title: "Artistas",
                subtitle: "Gestionar equipo",
                color: .brandPrimary,
                action: { selectedView = .artists }
            )

            QuickActionCard(
                icon: "calendar.badge.clock",
                title: "Asignación",
                subtitle: "Gestionar citas",
                color: .calendarEventBlue,
                action: { selectedView = .appointments }
            )

            QuickActionCard(
                icon: "calendar",
                title: "Calendario",
                subtitle: "Vista compartida",
                color: .calendarEventPink,
                action: { selectedView = .calendar }
            )

            QuickActionCard(
                icon: "chart.bar.fill",
                title: "Reportes",
                subtitle: "Analytics",
                color: .successGreen,
                action: { selectedView = .reports }
            )
        }
    }

    // MARK: - Today Schedule
    private var todayScheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Agenda de Hoy")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(todayAppointments.count) citas")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.brandPrimary.opacity(0.1)))
            }

            if todayAppointments.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.checkmark",
                    title: "Sin citas programadas hoy",
                    message: ""
                )
                .frame(height: 150)
            } else {
                VStack(spacing: 12) {
                    ForEach(todayAppointments.prefix(3)) { appointment in
                        CompactAppointmentRow(appointment: appointment)
                    }

                    if todayAppointments.count > 3 {
                        Button(action: { selectedView = .appointments }) {
                            Text("Ver todas (\(todayAppointments.count))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.brandPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.brandPrimary.opacity(0.1))
                                )
                        }
                    }
                }
            }
        }
        .padding(16)
        .modernCard()
    }

    // MARK: - Upcoming Appointments
    private var upcomingAppointmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Próximas Citas")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)

                Spacer()

                Button(action: { selectedView = .appointments }) {
                    HStack(spacing: 4) {
                        Text("Ver todas")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.brandPrimary)
                }
            }

            if upcomingAppointments.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No hay citas próximas",
                    message: ""
                )
                .frame(height: 150)
            } else {
                VStack(spacing: 12) {
                    ForEach(upcomingAppointments.prefix(5)) { appointment in
                        UpcomingAppointmentRow(appointment: appointment)
                    }
                }
            }
        }
        .padding(16)
        .modernCard()
    }

    // MARK: - Sheet Views
    @ViewBuilder
    private func viewSheet(for view: DashboardView) -> some View {
        switch view {
        case .artists:
            ArtistsManagementView()
        case .appointments:
            AppointmentAssignmentView()
        case .calendar:
            SharedCalendarView()
        case .reports:
            StudioReportsView()
        }
    }
}

// MARK: - Dashboard View Enum
enum DashboardView: Identifiable {
    case artists
    case appointments
    case calendar
    case reports

    var id: String {
        switch self {
        case .artists: return "artists"
        case .appointments: return "appointments"
        case .calendar: return "calendar"
        case .reports: return "reports"
        }
    }
}

// MARK: - Compact Appointment Row
private struct CompactAppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(appointment.status.colorValue)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.clientName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(appointment.timeRange)
                            .font(.system(size: 11))
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 10))
                        Text(appointment.artistName)
                            .font(.system(size: 11))
                    }
                }
                .foregroundColor(.textSecondary)
            }

            Spacer()

            Text(String(format: "%.0f€", appointment.price))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.textPrimary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.backgroundTertiary.opacity(0.3))
        )
    }
}

// MARK: - Upcoming Appointment Row
private struct UpcomingAppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(appointment.startDate.formatted(.dateTime.day()))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(appointment.startDate.formatted(.dateTime.month(.abbreviated)))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.clientName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)

                Text(appointment.service)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 9))
                    Text(appointment.artistName)
                        .font(.system(size: 11))
                }
                .foregroundColor(.brandPrimary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(appointment.startDate.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textPrimary)

                Text(String(format: "%.0f€", appointment.price))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.successGreen)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.backgroundTertiary.opacity(0.3))
        )
    }
}

#Preview {
    StudioDashboardView()
        .modelContainer(for: [Appointment.self, Artist.self], inMemory: true)
}
