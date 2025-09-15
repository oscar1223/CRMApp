import SwiftUI

// MARK: - App Tab Enum
enum AppTab: Int, CaseIterable {
    case calendar = 1
    case booking = 2
    case chat = 3
    case settings = 4
    
    var title: String {
        switch self {
        case .calendar: return "Calendario"
        case .booking: return "Reservas"
        case .chat: return "Chat"
        case .settings: return "Ajustes"
        }
    }
    
    var emoji: String {
        switch self {
        case .calendar: return "📆"
        case .booking: return "📖"
        case .chat: return "🤖"
        case .settings: return "⚙️"
        }
    }
}

// MARK: - Mock Event Model (Local)
struct MockEvent: Identifiable, Codable {
    var id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    
    init(title: String, startDate: Date, endDate: Date, isAllDay: Bool = false) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .calendar
    private let tabBarBottomInset: CGFloat = 88
    
    // Calendar state
    @State private var calendarViewMode: CalendarPage.ViewMode = .month
    @State private var calendarSelectedDate: Date = Date()
    @State private var calendarCurrentMonthAnchor: Date = Date()
    @State private var calendarEventsCountByDay: [Date: Int] = [:]
    @State private var calendarEventsByDay: [Date: [MockEvent]] = [:]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.white, Color(red: 0.96, green: 0.97, blue: 0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Add minimal top padding
                Spacer()
                    .frame(height: 24)
                
                VStack {
                    switch selectedTab {
                    case .calendar:
                        CalendarTabView(
                            selectedDate: $calendarSelectedDate,
                            currentMonthAnchor: $calendarCurrentMonthAnchor,
                            viewMode: $calendarViewMode,
                            eventsCountByDay: $calendarEventsCountByDay,
                            eventsByDay: $calendarEventsByDay
                        )
                    case .booking:
                        ComingSoonView(
                            title: "Reservas",
                            subtitle: "Gestiona tus citas y reservas",
                            emoji: "📅"
                        )
                    case .chat:
                        ComingSoonView(
                            title: "Asistente IA",
                            subtitle: "Tu asistente personal inteligente",
                            emoji: "🤖"
                        )
                    case .settings:
                        ComingSoonView(
                            title: "Configuración",
                            subtitle: "Personaliza tu experiencia",
                            emoji: "⚙️"
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, tabBarBottomInset)
            }
            
            // Bottom tab bar
            VStack {
                Spacer()
                SimpleTabBar(selectedTab: $selectedTab)
                    .frame(maxWidth: 320)
                    .padding(.horizontal, 16)
                    .padding(.bottom, safeBottomPadding)
            }
        }
    }
    
    private var safeBottomPadding: CGFloat {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let inset = scene.windows.first?.safeAreaInsets.bottom else { return 4 }
        return max(4, inset + 2)
    }
}

// MARK: - Coming Soon View
struct ComingSoonView: View {
    let title: String
    let subtitle: String
    let emoji: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 64))
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 12) {
                Text("Próximamente")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
                
                Text("Esta función estará disponible en una próxima actualización")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Calendar Tab View
struct CalendarTabView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonthAnchor: Date
    @Binding var viewMode: CalendarPage.ViewMode
    @Binding var eventsCountByDay: [Date: Int]
    @Binding var eventsByDay: [Date: [MockEvent]]
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentPageTitle)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(formattedCurrentDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        // Add event button
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                addNewEvent()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Nuevo")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        // View mode toggle button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                cycleCalendarViewMode()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text(viewMode.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .rotationEffect(.degrees(viewMode == .month ? 0 : 180))
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            CalendarPage(
                selectedDate: $selectedDate,
                currentMonthAnchor: $currentMonthAnchor,
                viewMode: $viewMode,
                eventsCountByDay: $eventsCountByDay,
                eventsByDay: $eventsByDay
            )
        }
    }
    
    private var currentPageTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return formatter.string(from: currentMonthAnchor)
    }
    
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("EEEE, d 'de' MMMM")
        return formatter.string(from: Date())
    }
    
    private func cycleCalendarViewMode() {
        switch viewMode {
        case .month:
            viewMode = .week
        case .week:
            viewMode = .month
        }
    }
    
    private func addNewEvent() {
        // Create a new mock event for today
        let today = Date()
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
        let endTime = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: today) ?? today
        
        let newEvent = MockEvent(
            title: "Nueva Cita",
            startDate: startTime,
            endDate: endTime
        )
        
        // Add to events
        let dayStart = calendar.startOfDay(for: today)
        eventsByDay[dayStart, default: []].append(newEvent)
        eventsCountByDay[dayStart, default: 0] += 1
        
        // Select today's date
        selectedDate = today
    }
}

// MARK: - Calendar Page
struct CalendarPage: View {
    @Binding var selectedDate: Date
    @Binding var currentMonthAnchor: Date
    @Binding var viewMode: ViewMode
    @Binding var eventsCountByDay: [Date: Int]
    @Binding var eventsByDay: [Date: [MockEvent]]
    
    enum ViewMode: String, CaseIterable, Identifiable {
        case month = "Mes"
        case week = "Semana"
        var id: String { rawValue }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Group {
                switch viewMode {
                case .month:
                    SimpleCalendarView(
                        selectedDate: $selectedDate,
                        monthAnchor: $currentMonthAnchor,
                        eventsCountByDay: eventsCountByDay,
                        eventsByDay: eventsByDay,
                        onMonthChanged: { delta in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentMonthAnchor = Calendar.current.date(byAdding: .month, value: delta, to: currentMonthAnchor) ?? currentMonthAnchor
                                selectedDate = clampSelectedDateToMonth(selectedDate, monthAnchor: currentMonthAnchor)
                                loadMockEvents()
                            }
                        },
                        onSelectDate: { date in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDate = date
                            }
                        }
                    )
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 24)
                    
                case .week:
                    SimpleWeekView(selectedDate: $selectedDate)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .padding(.horizontal, 24)
                }
            }
            
            // Events section
            if !getEventsForSelectedDate().isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Eventos")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text(formattedSelectedDate)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Ver todos")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    SimpleEventsList(events: getEventsForSelectedDate())
                        .frame(maxHeight: 240)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .padding(.horizontal, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                // Empty state
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Sin eventos")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("No tienes eventos para \(formattedSelectedDate)")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: { /* addNewEvent() */ }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .medium))
                            Text("Crear evento")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .padding(.horizontal, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .task { loadMockEvents() }
    }
    
    private func loadMockEvents() {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: currentMonthAnchor)
        guard let monthStart = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: 1)) else { return }
        let monthRange = cal.range(of: .day, in: .month, for: monthStart) ?? (1..<29)
        let lastDay = monthRange.count
        let monthEnd = cal.date(byAdding: DateComponents(day: lastDay, hour: 23, minute: 59, second: 59), to: monthStart) ?? monthStart
        
        // Create some mock events for demonstration
        var counts: [Date: Int] = [:]
        var eventsByDayDict: [Date: [MockEvent]] = [:]
        
        // Add some sample events
        let sampleEvents = createSampleEvents(for: monthStart, to: monthEnd)
        
        for event in sampleEvents {
            let day = cal.startOfDay(for: event.startDate)
            counts[day, default: 0] += 1
            eventsByDayDict[day, default: []].append(event)
        }
        
        eventsCountByDay = counts
        eventsByDay = eventsByDayDict
    }
    
    private func createSampleEvents(for monthStart: Date, to monthEnd: Date) -> [MockEvent] {
        var events: [MockEvent] = []
        let cal = Calendar.current
        
        // Add a few sample events
        if let day1 = cal.date(byAdding: .day, value: 5, to: monthStart),
           let day2 = cal.date(byAdding: .day, value: 10, to: monthStart),
           let day3 = cal.date(byAdding: .day, value: 15, to: monthStart) {
            
            events.append(MockEvent(
                title: "Reunión de equipo",
                startDate: cal.date(bySettingHour: 10, minute: 0, second: 0, of: day1) ?? day1,
                endDate: cal.date(bySettingHour: 11, minute: 30, second: 0, of: day1) ?? day1
            ))
            
            events.append(MockEvent(
                title: "Presentación cliente",
                startDate: cal.date(bySettingHour: 14, minute: 0, second: 0, of: day2) ?? day2,
                endDate: cal.date(bySettingHour: 15, minute: 0, second: 0, of: day2) ?? day2
            ))
            
            events.append(MockEvent(
                title: "Sesión de trabajo",
                startDate: cal.date(bySettingHour: 9, minute: 0, second: 0, of: day3) ?? day3,
                endDate: cal.date(bySettingHour: 12, minute: 0, second: 0, of: day3) ?? day3
            ))
        }
        
        return events
    }
    
    private func getEventsForSelectedDate() -> [MockEvent] {
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        return eventsByDay[dayStart] ?? []
    }

    private func clampSelectedDateToMonth(_ date: Date, monthAnchor: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: monthAnchor)
        guard let monthStart = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: 1)) else { return date }
        let range = cal.range(of: .day, in: .month, for: monthStart) ?? (1..<29)
        let clampedDay = min(cal.component(.day, from: date), range.count)
        return cal.date(from: DateComponents(year: comps.year, month: comps.month, day: clampedDay)) ?? date
    }
    
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("d 'de' MMMM")
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Simple Calendar View
struct SimpleCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var monthAnchor: Date
    let eventsCountByDay: [Date: Int]
    let eventsByDay: [Date: [MockEvent]]
    var onMonthChanged: (Int) -> Void
    var onSelectDate: (Date) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 20) {
            // Month navigation header
            HStack {
                Button(action: { onMonthChanged(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color(.systemGray6)))
                }
                
                Spacer()
                
                Button(action: { onMonthChanged(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color(.systemGray6)))
                }
            }
            
            // Week days header
            let symbols = calendar.veryShortStandaloneWeekdaySymbols
            let startIndex = calendar.firstWeekday - 1
            let ordered = Array(symbols[startIndex...] + symbols[..<startIndex])
            
            HStack {
                ForEach(ordered, id: \.self) { symbol in
                    Text(symbol.uppercased())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(monthDaysGrid, id: \.self) { day in
                    dayCell(day)
                }
            }
        }
    }
    
    private var monthDaysGrid: [Date] {
        let monthStart = getMonthStart()
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        let firstWeekdayOffset = getFirstWeekdayOffset(for: monthStart)
        
        var days: [Date] = []
        
        // Previous month padding
        if let prevStart = calendar.date(byAdding: .day, value: -firstWeekdayOffset, to: monthStart) {
            for i in 0..<firstWeekdayOffset {
                let d = calendar.date(byAdding: .day, value: i, to: prevStart)!
                days.append(d)
            }
        }
        
        // Current month
        for i in 0..<daysInMonth {
            let d = calendar.date(byAdding: .day, value: i, to: monthStart)!
            days.append(d)
        }
        
        // Next month padding to 6 weeks (42 cells)
        let remaining = max(0, 42 - days.count)
        if let last = days.last {
            for i in 1...remaining {
                let d = calendar.date(byAdding: .day, value: i, to: last)!
                days.append(d)
            }
        }
        
        return days
    }
    
    private func getMonthStart() -> Date {
        let comps = calendar.dateComponents([.year, .month], from: monthAnchor)
        return calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: 1)) ?? monthAnchor
    }
    
    private func getFirstWeekdayOffset(for monthStart: Date) -> Int {
        let weekday = calendar.component(.weekday, from: monthStart)
        let first = calendar.firstWeekday
        return (weekday - first + 7) % 7
    }
    
    private func dayCell(_ date: Date) -> some View {
        let monthStart = getMonthStart()
        let isInCurrentMonth = calendar.isDate(date, equalTo: monthStart, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let dayEvents = eventsByDay[calendar.startOfDay(for: date)] ?? []
        
        return VStack(spacing: 0) {
            // Day number
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.clear))
                    .frame(width: 32, height: 32)
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday || isSelected ? .semibold : .regular)
                    .foregroundColor(
                        isSelected ? .white : 
                        (isToday ? .blue : 
                         (isInCurrentMonth ? .primary : .secondary))
                    )
            }
            
            // Event indicators
            HStack(spacing: 2) {
                ForEach(Array(dayEvents.prefix(3).enumerated()), id: \.offset) { index, _ in
                    Circle()
                        .fill(eventColor(for: index))
                        .frame(width: 4, height: 4)
                }
                
                if dayEvents.count > 3 {
                    Text("+")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 12)
        }
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectDate(date)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func eventColor(for index: Int) -> Color {
        let colors: [Color] = [.orange, .blue, .purple, .green]
        return colors[index % colors.count]
    }
}

// MARK: - Simple Week View
struct SimpleWeekView: View {
    @Binding var selectedDate: Date
    
    private var weekDays: [Date] {
        let start = startOfWeek(for: selectedDate)
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: start) }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(weekDays, id: \.self) { day in
                    weekDayCell(day)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func weekDayCell(_ date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(date)
        
        return VStack(spacing: 8) {
            Text(shortWeekday(for: date))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color(.systemGray6)))
                    .frame(width: 48, height: 48)
                
                Text(dayNumber(for: date))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
            }
        }
        .frame(width: 56)
        .contentShape(Rectangle())
        .onTapGesture { selectedDate = date }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func shortWeekday(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate("EEE")
        return f.string(from: date).uppercased()
    }
    
    private func dayNumber(for date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return String(day)
    }
    
    private func startOfWeek(for date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }
}

// MARK: - Simple Events List
struct SimpleEventsList: View {
    let events: [MockEvent]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(events, id: \.id) { event in
                    SimpleEventCard(event: event)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Simple Event Card
struct SimpleEventCard: View {
    let event: MockEvent
    
    var body: some View {
        HStack(spacing: 16) {
            // Event time indicator
            VStack(spacing: 4) {
                Text(timeString(for: event.startDate))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                if !event.isAllDay {
                    Text(timeString(for: event.endDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 50)
            
            // Event content
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.orange)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if event.isAllDay {
                        Text("Todo el día")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text(durationString(for: event))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray5), lineWidth: 0.5)
                    )
            )
        }
    }
    
    private func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func durationString(for event: MockEvent) -> String {
        let duration = event.endDate.timeIntervalSince(event.startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Simple Tab Bar
struct SimpleTabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
    }
    
    private func tabButton(for tab: AppTab) -> some View {
        Button(action: { 
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(selectedTab == tab ? Color.blue : Color.clear)
                        .frame(width: 40, height: 40)
                    
                    Text(tab.emoji)
                        .font(.system(size: 20))
                        .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                }
                
                Text(tab.title)
                    .font(.caption)
                    .fontWeight(selectedTab == tab ? .semibold : .medium)
                    .foregroundColor(selectedTab == tab ? .blue : .secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}