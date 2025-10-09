import SwiftUI
import SwiftData
import Charts

// MARK: - Studio Reports View
struct StudioReportsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appointments: [Appointment]
    @Query private var artists: [Artist]

    @State private var selectedPeriod: ReportPeriod = .month
    @State private var selectedMetric: ReportMetric = .revenue

    // MARK: - Computed Statistics
    private var periodAppointments: [Appointment] {
        let calendar = Calendar.current
        let now = Date()

        return appointments.filter { appointment in
            switch selectedPeriod {
            case .week:
                return calendar.isDate(appointment.startDate, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(appointment.startDate, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(appointment.startDate, equalTo: now, toGranularity: .year)
            }
        }
    }

    private var totalRevenue: Double {
        periodAppointments
            .filter { $0.status == .completed }
            .reduce(0) { $0 + $1.price }
    }

    private var totalAppointments: Int {
        periodAppointments.count
    }

    private var completedAppointments: Int {
        periodAppointments.filter { $0.status == .completed }.count
    }

    private var cancelledAppointments: Int {
        periodAppointments.filter { $0.status == .cancelled }.count
    }

    private var averageTicket: Double {
        guard completedAppointments > 0 else { return 0 }
        return totalRevenue / Double(completedAppointments)
    }

    private var artistsPerformance: [(Artist, Double, Int)] {
        artists.map { artist in
            let artistAppointments = periodAppointments.filter { $0.artistName == artist.name && $0.status == .completed }
            let revenue = artistAppointments.reduce(0.0) { $0 + $1.price }
            let count = artistAppointments.count
            return (artist, revenue, count)
        }
        .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        ZStack {
            Color.clear.studioBackground()

            ScrollView {
                VStack(spacing: UIDevice.isIPad ? 24 : 20) {
                    headerSection
                    periodSelector
                    statsOverviewSection
                    chartSection
                    artistsPerformanceSection
                    appointmentsBreakdownSection

                    Spacer(minLength: 100)
                }
                .modernPadding(.horizontal, .medium)
                .modernPadding(.top, .large)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Reportes del Estudio")
                .modernText(size: UIDevice.isIPad ? .title : .headline, color: .textPrimary)
                .fontWeight(.bold)

            Text("Análisis y métricas de rendimiento")
                .modernText(size: UIDevice.isIPad ? .subhead : .caption, color: .textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(ReportPeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedPeriod == period ? .white : .textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedPeriod == period ? Color.brandPrimary : Color.clear)
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
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    // MARK: - Stats Overview
    private var statsOverviewSection: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: UIDevice.isIPad ? 4 : 2),
            spacing: 12
        ) {
            StatCard(
                icon: "eurosign.circle.fill",
                title: "Ingresos",
                value: String(format: "%.0f€", totalRevenue),
                color: .successGreen,
                style: .default
            )

            StatCard(
                icon: "calendar.circle.fill",
                title: "Citas",
                value: "\(totalAppointments)",
                color: .brandPrimary,
                style: .default
            )

            StatCard(
                icon: "checkmark.seal.fill",
                title: "Completadas",
                value: "\(completedAppointments)",
                color: .calendarEventBlue,
                style: .default
            )

            StatCard(
                icon: "chart.bar.fill",
                title: "Ticket Medio",
                value: String(format: "%.0f€", averageTicket),
                color: .warningOrange,
                style: .default
            )
        }
    }

    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tendencia")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)

                Spacer()

                // Metric selector
                Menu {
                    ForEach(ReportMetric.allCases, id: \.self) { metric in
                        Button(action: { selectedMetric = metric }) {
                            HStack {
                                Text(metric.displayName)
                                if selectedMetric == metric {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedMetric.displayName)
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.brandPrimary.opacity(0.1))
                    )
                }
            }

            revenueChart
                .frame(height: UIDevice.isIPad ? 250 : 200)
        }
        .padding(16)
        .modernCard()
    }

    private var revenueChart: some View {
        let data = getChartData()

        return Chart(data) { item in
            LineMark(
                x: .value("Día", item.label),
                y: .value("Valor", item.value)
            )
            .foregroundStyle(Color.brandPrimary)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Día", item.label),
                y: .value("Valor", item.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.brandPrimary.opacity(0.3), Color.brandPrimary.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.system(size: 10))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.system(size: 10))
                    .foregroundStyle(Color.textTertiary)
            }
        }
    }

    // MARK: - Artists Performance
    private var artistsPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rendimiento por Artista")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)

            if artistsPerformance.isEmpty {
                EmptyStateView(
                    icon: "chart.bar",
                    title: "Sin datos",
                    message: "No hay datos para este período"
                )
                .frame(height: 150)
            } else {
                ForEach(artistsPerformance, id: \.0.id) { item in
                    ArtistPerformanceRow(
                        artist: item.0,
                        revenue: item.1,
                        appointments: item.2
                    )
                }
            }
        }
        .padding(16)
        .modernCard()
    }

    // MARK: - Appointments Breakdown
    private var appointmentsBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Desglose de Citas")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)

            HStack(spacing: 12) {
                BreakdownCard(
                    title: "Completadas",
                    value: completedAppointments,
                    total: totalAppointments,
                    color: .successGreen
                )

                BreakdownCard(
                    title: "Canceladas",
                    value: cancelledAppointments,
                    total: totalAppointments,
                    color: .errorRed
                )
            }
        }
        .padding(16)
        .modernCard()
    }

    // MARK: - Chart Data Helper
    private func getChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedPeriod {
        case .week:
            return (0..<7).compactMap { day in
                guard let date = calendar.date(byAdding: .day, value: -day, to: now) else { return nil }
                let dayAppointments = appointments.filter {
                    calendar.isDate($0.startDate, inSameDayAs: date) && $0.status == .completed
                }

                let value: Double = selectedMetric == .revenue ?
                    dayAppointments.reduce(0.0) { $0 + $1.price } :
                    Double(dayAppointments.count)

                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                return ChartDataPoint(label: formatter.string(from: date), value: value)
            }.reversed()

        case .month:
            let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
            let step = max(daysInMonth / 7, 1)

            return stride(from: 0, to: daysInMonth, by: step).compactMap { day in
                guard let date = calendar.date(byAdding: .day, value: -day, to: now) else { return nil }
                let dayAppointments = appointments.filter {
                    calendar.isDate($0.startDate, inSameDayAs: date) && $0.status == .completed
                }

                let value: Double = selectedMetric == .revenue ?
                    dayAppointments.reduce(0.0) { $0 + $1.price } :
                    Double(dayAppointments.count)

                return ChartDataPoint(label: "\(calendar.component(.day, from: date))", value: value)
            }.reversed()

        case .year:
            return (0..<12).compactMap { month in
                guard let date = calendar.date(byAdding: .month, value: -month, to: now) else { return nil }
                let monthAppointments = appointments.filter {
                    calendar.isDate($0.startDate, equalTo: date, toGranularity: .month) && $0.status == .completed
                }

                let value: Double = selectedMetric == .revenue ?
                    monthAppointments.reduce(0.0) { $0 + $1.price } :
                    Double(monthAppointments.count)

                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                return ChartDataPoint(label: formatter.string(from: date), value: value)
            }.reversed()
        }
    }
}

// MARK: - Supporting Types
enum ReportPeriod: String, CaseIterable {
    case week = "Semana"
    case month = "Mes"
    case year = "Año"
}

enum ReportMetric: String, CaseIterable {
    case revenue = "revenue"
    case appointments = "appointments"

    var displayName: String {
        switch self {
        case .revenue: return "Ingresos"
        case .appointments: return "Citas"
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

// MARK: - Artist Performance Row
private struct ArtistPerformanceRow: View {
    let artist: Artist
    let revenue: Double
    let appointments: Int

    var body: some View {
        HStack(spacing: 12) {
            AvatarCircle(initials: artist.initials, size: 44)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(artist.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)

                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: "calendar")
                            .font(.system(size: 9))
                        Text("\(appointments) citas")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.textTertiary)

                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                        Text(String(format: "%.1f", artist.rating))
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.warningOrange)
                }
            }

            Spacer()

            // Revenue
            Text(String(format: "%.0f€", revenue))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.successGreen)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.backgroundTertiary.opacity(0.5))
        )
    }
}

// MARK: - Breakdown Card
private struct BreakdownCard: View {
    let title: String
    let value: Int
    let total: Int
    let color: Color

    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total) * 100
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(String(format: "%.0f%%", percentage))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.backgroundTertiary.opacity(0.5))
        )
    }
}

#Preview {
    StudioReportsView()
        .modelContainer(for: [Appointment.self, Artist.self], inMemory: true)
}
