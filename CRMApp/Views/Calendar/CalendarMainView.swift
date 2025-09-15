import SwiftUI

// MARK: - Calendar Main View
struct CalendarMainView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonthAnchor: Date
    @Binding var eventsCountByDay: [Date: Int]
    @Binding var eventsByDay: [Date: [MockEvent]]
    
    @State private var viewMode: ViewMode = .month
    
    enum ViewMode: String, CaseIterable {
        case month = "Mes"
        case week = "Semana"
    }
    
    // Responsive properties
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack(spacing: isIPad ? 16 : 12) {
            // Compact header
            calendarHeader
            
            // Calendar content with smoother transitions
            Group {
                switch viewMode {
                case .month:
                    MonthGrid(
                        selectedDate: $selectedDate,
                        monthAnchor: $currentMonthAnchor,
                        eventsCountByDay: eventsCountByDay,
                        eventsByDay: eventsByDay,
                        onMonthChanged: { delta in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentMonthAnchor = Calendar.current.date(byAdding: .month, value: delta, to: currentMonthAnchor) ?? currentMonthAnchor
                            }
                        },
                        onSelectDate: { date in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDate = date
                            }
                        }
                    )
                    .modernPadding(.horizontal, .small)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                case .week:
                    WeekStrip(selectedDate: $selectedDate)
                        .modernPadding(.horizontal, .small)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewMode)
            
            // Compact events section
            if !getEventsForSelectedDate().isEmpty {
                eventsSection
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: getEventsForSelectedDate().count)
            }
        }
        .modernPadding(.bottom, .small)
    }
    
    private var calendarHeader: some View {
        VStack(spacing: isIPad ? 12 : 8) {
            // Compact main title
            HStack {
                VStack(alignment: .leading, spacing: isIPad ? 6 : 4) {
                    Text(currentPageTitle)
                        .modernText(size: isIPad ? .headline : .body, color: .textPrimary)
                        .fontWeight(.bold)
                    
                    Text(formattedCurrentDate)
                        .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Compact action buttons
                HStack(spacing: isIPad ? 12 : 8) {
                    Button(action: { addNewEvent() }) {
                        HStack(spacing: isIPad ? 6 : 4) {
                            Image(systemName: "plus")
                                .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                            Text("Nuevo")
                                .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                        }
                    }
                    .modernButton(style: .primary)
                    
                    Button(action: { toggleViewMode() }) {
                        HStack(spacing: isIPad ? 4 : 3) {
                            Text(viewMode.rawValue)
                                .font(.system(size: isIPad ? 14 : 12, weight: .medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: isIPad ? 12 : 10, weight: .medium))
                                .rotationEffect(.degrees(viewMode == .month ? 0 : 180))
                        }
                    }
                    .modernButton(style: .secondary)
                }
            }
            .modernPadding(.horizontal, .medium)
            .modernPadding(.top, .small)
            
            // Compact selected date indicator
            selectedDateIndicator
        }
    }
    
    private var selectedDateIndicator: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Fecha seleccionada")
                    .modernText(size: .small, color: .textTertiary)
                    .fontWeight(.medium)
                
                Text(formattedSelectedDate)
                    .modernText(size: isIPad ? .subhead : .caption, color: .brandPrimary)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            // Compact event count badge
            if !getEventsForSelectedDate().isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: isIPad ? 12 : 10, weight: .medium))
                        .foregroundColor(Color.brandPrimary)
                    
                    Text("\(getEventsForSelectedDate().count)")
                        .modernText(size: .small, color: .brandPrimary)
                        .fontWeight(.semibold)
                }
                .modernPadding(.horizontal, .small)
                .modernPadding(.vertical, .xsmall)
                .background(
                    Capsule()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(Color.brandPrimary.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .modernPadding(.horizontal, .medium)
        .modernPadding(.vertical, .small)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                .fill(Color.backgroundTertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                        .stroke(Color.borderLight, lineWidth: 0.5)
                )
        )
        .modernPadding(.horizontal, .medium)
    }
    
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: isIPad ? 12 : 8) {
            // Compact section header
            HStack {
                VStack(alignment: .leading, spacing: isIPad ? 4 : 2) {
                    Text("Eventos")
                        .modernText(size: isIPad ? .body : .subhead, color: .textPrimary)
                        .fontWeight(.bold)
                    
                    Text(formattedSelectedDate)
                        .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
                        .fontWeight(.medium)
                }
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: isIPad ? 4 : 3) {
                        Text("Ver todos")
                            .modernText(size: isIPad ? .subhead : .caption, color: .brandPrimary)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                            .font(.system(size: isIPad ? 12 : 10, weight: .semibold))
                            .foregroundColor(Color.brandPrimary)
                    }
                }
                .modernButton(style: .ghost)
            }
            .modernPadding(.horizontal, .medium)
            .modernPadding(.top, .small)
            
            // Compact events list
            EventsList(events: getEventsForSelectedDate())
                .frame(maxHeight: isIPad ? 200 : 150)
                .background(
                    RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                        .fill(Color.backgroundSecondary)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                )
        }
        .modernCard()
        .modernPadding(.horizontal, .small)
    }
    
    private var currentPageTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return formatter.string(from: currentMonthAnchor).capitalized
    }
    
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("EEEE, d 'de' MMMM")
        return formatter.string(from: Date()).capitalized
    }
    
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("d 'de' MMMM")
        return formatter.string(from: selectedDate).capitalized
    }
    
    private func toggleViewMode() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewMode = viewMode == .month ? .week : .month
        }
    }
    
    private func addNewEvent() {
        let today = Date()
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
        let endTime = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: today) ?? today
        
        let newEvent = MockEvent(
            title: "Nueva Cita",
            startDate: startTime,
            endDate: endTime
        )
        
        let dayStart = calendar.startOfDay(for: today)
        eventsByDay[dayStart, default: []].append(newEvent)
        eventsCountByDay[dayStart, default: 0] += 1
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedDate = today
        }
    }
    
    private func getEventsForSelectedDate() -> [MockEvent] {
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        return eventsByDay[dayStart] ?? []
    }
}