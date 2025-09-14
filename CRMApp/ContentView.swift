import SwiftUI

struct ContentView: View {
    enum Tab: Int, CaseIterable { case one = 1, two = 2, three = 3, four = 4 }
    @State private var selectedTab: Tab = .one
    private let tabBarBottomInset: CGFloat = 88
    
    // Calendar state for buttons
    @State private var calendarViewMode: CalendarPage.ViewMode = .month
    @State private var calendarSelectedDate: Date = Date()
    @State private var calendarCurrentMonthAnchor: Date = Date()
    @State private var calendarEventsCountByDay: [Date: Int] = [:]
    @State private var calendarEventsByDay: [Date: [MockEvent]] = [:]
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Add minimal top padding
                Spacer()
                    .frame(height: 20)
                
                Group {
                    switch selectedTab {
                    case .one:
                        VStack(spacing: 40) {
                            // Month/Year header with buttons
                            HStack {
                                Text(currentPageTitle)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Add event button
                                Button(action: {
                                    // Handle add event
                                    addNewEvent()
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .fill(Color.accentColor)
                                        )
                                }
                                .buttonStyle(.plain)
                                
                                // View mode toggle button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        cycleCalendarViewMode()
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Text(calendarViewMode.rawValue)
                                            .font(.system(size: 16, weight: .medium))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(.secondarySystemBackground))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 15)
                            
                            CalendarPage(
                                selectedDate: $calendarSelectedDate,
                                currentMonthAnchor: $calendarCurrentMonthAnchor,
                                viewMode: $calendarViewMode,
                                eventsCountByDay: $calendarEventsCountByDay,
                                eventsByDay: $calendarEventsByDay
                            )
                        }
                    case .two:
                        BookingSettingsPage()
                    case .three:
                        ChatBotPage()
                    case .four:
                        SettingsPage()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .padding(.bottom, tabBarBottomInset)
            }
            
            // Floating navbar
            VStack {

                Spacer()
            }
            
            // Bottom tab bar
            VStack {
                Spacer()
                FloatingTabBar(selectedTab: $selectedTab)
                    .frame(maxWidth: 360)
                    .padding(.bottom, safeBottomPadding)
            }
        }
    }
    
    private var currentPageTitle: String {
        switch selectedTab {
        case .one:
            return formattedMonthYear(calendarCurrentMonthAnchor)
        case .two:
            return "Reservas"
        case .three:
            return "Chatbot"
        case .four:
            return "Ajustes"
        }
    }
    
    private func formattedMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return formatter.string(from: date)
    }
    
    private func cycleCalendarViewMode() {
        switch calendarViewMode {
        case .month:
            calendarViewMode = .week
        case .week:
            calendarViewMode = .month
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
        calendarEventsByDay[dayStart, default: []].append(newEvent)
        calendarEventsCountByDay[dayStart, default: 0] += 1
        
        // Select today's date
        calendarSelectedDate = today
    }
}

#Preview {
    ContentView()
}

// MARK: - Screens
private struct NumberedScreen: View {
    let number: Int
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            Text("\(number)")
                .font(.system(size: 120, weight: .bold))
        }
    }
}

// MARK: - Mock Event Model
private struct MockEvent: Identifiable {
    let id = UUID()
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

// MARK: - Calendar (Tab 1)
private struct CalendarPage: View {
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
        VStack(spacing: 35) {
            Group {
                    switch viewMode {
                    case .month:
                        MonthGrid(
                            selectedDate: $selectedDate,
                            monthAnchor: $currentMonthAnchor,
                            eventsCountByDay: eventsCountByDay,
                            eventsByDay: eventsByDay,
                            onMonthChanged: { delta in
                                currentMonthAnchor = Calendar.current.date(byAdding: .month, value: delta, to: currentMonthAnchor) ?? currentMonthAnchor
                                selectedDate = clampSelectedDateToMonth(selectedDate, monthAnchor: currentMonthAnchor)
                                loadMockEvents()
                            },
                            onSelectDate: { date in
                                selectedDate = date
                            }
                        )
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 520)
                    case .week:
                        WeekStrip(selectedDate: $selectedDate)
                            .padding(.horizontal)
                    }
                }
                
                // Mock events list
                EventsList(events: getEventsForSelectedDate())
                    .overlay(Group { 
                        if getEventsForSelectedDate().isEmpty { 
                            Text("Sin eventos para esta fecha").foregroundColor(.secondary) 
                        } 
                    })
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
    
    private func formattedMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return formatter.string(from: date)
    }
}

// MARK: - Calendar subviews
private struct WeekStrip: View {
    @Binding var selectedDate: Date
    
    private var weekDays: [Date] {
        let start = startOfWeek(for: selectedDate)
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: start) }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.self) { day in
                let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                VStack(spacing: 6) {
                    Text(shortWeekday(for: day))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(dayNumber(for: day))
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
                        )
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { selectedDate = day }
                .foregroundColor(isSelected ? .accentColor : .primary)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground))
        )
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

private struct DayHeader: View {
    let date: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formatted(date: date, template: "EEEE, d 'de' MMMM"))
                .font(.title2).bold()
            Text(formatted(date: date, template: "y"))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private func formatted(date: Date, template: String) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate(template)
        return f.string(from: date)
    }
}

private struct EventsList: View {
    let events: [MockEvent]
    var body: some View {
        List(events, id: \.id) { event in
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(dateRangeString(for: event))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(.plain)
    }
    private func dateRangeString(for event: MockEvent) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        if event.isAllDay {
            return "Todo el día"
        } else {
            return "\(formatter.string(from: event.startDate)) – \(formatter.string(from: event.endDate))"
        }
    }
}

// MARK: - Month Grid (Apple Calendar-like)
private struct MonthGrid: View {
    @Binding var selectedDate: Date
    @Binding var monthAnchor: Date
    let eventsCountByDay: [Date: Int]
    let eventsByDay: [Date: [MockEvent]]
    var onMonthChanged: (Int) -> Void
    var onSelectDate: (Date) -> Void
    
    private let calendar = Calendar.current
    
    private var monthStart: Date {
        let comps = calendar.dateComponents([.year, .month], from: monthAnchor)
        return calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: 1)) ?? monthAnchor
    }
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
    }
    private var firstWeekdayOffset: Int {
        // 0-based index aligned to calendar.firstWeekday
        let weekday = calendar.component(.weekday, from: monthStart)
        let first = calendar.firstWeekday
        return (weekday - first + 7) % 7
    }
    private var monthDaysGrid: [Date] {
        var days: [Date] = []
        // Previous month padding
        if let prevStart = calendar.date(byAdding: .day, value: -firstWeekdayOffset, to: monthStart) {
            for i in 0..<(firstWeekdayOffset) {
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
    
    var body: some View {
        VStack(spacing: 25) {
            header
            weekdaysHeader
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 6) {
                ForEach(monthDaysGrid, id: \.self) { day in
                    dayCell(day)
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button { onMonthChanged(-1) } label: { Image(systemName: "chevron.left").font(.headline) }
            Spacer()
            Button { onMonthChanged(1) } label: { Image(systemName: "chevron.right").font(.headline) }
        }
        .padding(.vertical, 20)
    }
    
    private var weekdaysHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let startIndex = calendar.firstWeekday - 1
        let ordered = Array(symbols[startIndex...] + symbols[..<startIndex])
        return HStack {
            ForEach(ordered, id: \.self) { s in
                Text(s.uppercased())
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func dayCell(_ date: Date) -> some View {
        let isInCurrentMonth = calendar.isDate(date, equalTo: monthStart, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let dayEvents = eventsByDay[calendar.startOfDay(for: date)] ?? []
        _ = eventsCountByDay[calendar.startOfDay(for: date)] ?? 0
        
        return VStack(spacing: 0) {
            // Day number header
            HStack {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .medium))
                    .foregroundColor(isInCurrentMonth ? (isToday ? .accentColor : .primary) : .secondary)
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
            
            // Event previews box
            VStack(spacing: 2) {
                if !dayEvents.isEmpty {
                    ForEach(Array(dayEvents.prefix(2)), id: \.id) { event in
                        eventPreview(event)
                    }
                    if dayEvents.count > 2 {
                        Text("+\(dayEvents.count - 2)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.tertiarySystemBackground))
                            )
                    }
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 2)
            .padding(.bottom, 2)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isToday ? Color.accentColor : Color.clear,
                            lineWidth: isToday ? 1 : 0
                        )
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedDate = date
            onSelectDate(date)
        }
    }
    
    private func eventPreview(_ event: MockEvent) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 4, height: 4)
            Text(event.title)
                .font(.caption2)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 1)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.accentColor.opacity(0.1))
        )
    }
    
    
    private func formattedMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate("yMMMM")
        return f.string(from: date)
    }
}

// MARK: - Chatbot (Tab 3)
private struct ChatMessage: Identifiable, Hashable {
    enum Role { case user, bot }
    let id = UUID()
    let role: Role
    let text: String
    let timestamp: Date
}

// MARK: - Booking settings (Tab 2)
private struct BookingLink: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var url: String
    init(id: UUID = UUID(), title: String, url: String) {
        self.id = id; self.title = title; self.url = url
    }
}

// MARK: - Settings (Tab 4)
private struct AppSettings: Codable, Hashable {
    struct Profile: Codable, Hashable { var firstName: String; var lastName: String; var email: String }
    struct Payment: Codable, Hashable { var method: String; var gatewayEnabled: Bool }
    var profile: Profile
    var payment: Payment
    var onboardingQuestions: String
    var feedback: String
}

private final class SettingsStore: ObservableObject {
    @Published var settings: AppSettings
    private let key = "AppSettings.v1"
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .init(
                profile: .init(firstName: "", lastName: "", email: ""),
                payment: .init(method: "Tarjeta", gatewayEnabled: false),
                onboardingQuestions: "",
                feedback: ""
            )
        }
    }
    func save() {
        if let data = try? JSONEncoder().encode(settings) { UserDefaults.standard.set(data, forKey: key) }
    }
}

private struct SettingsPage: View {
    @StateObject private var store = SettingsStore()
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Photo
                    Button(action: { showingImagePicker = true }) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 100, height: 100)
                            
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Edit overlay
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            .frame(width: 100, height: 100)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text("\(store.settings.profile.firstName) \(store.settings.profile.lastName)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(store.settings.profile.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Edit Profile Button
                    Button("Editar Perfil") {
                        // Handle edit profile
                    }
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                }
                .padding(.top, 20)
                
                // Settings Sections
                VStack(spacing: 16) {
                    SettingsSection(title: "Configuración", items: [
                        SettingsItem(title: "Payment Methods", icon: "creditcard.fill", color: .green),
                        SettingsItem(title: "Workplaces", icon: "building.2.fill", color: .blue),
                        SettingsItem(title: "Location", icon: "location.fill", color: .red),
                        SettingsItem(title: "Availability", icon: "clock.fill", color: .orange),
                        SettingsItem(title: "Booking Requests", icon: "calendar.badge.plus", color: .purple),
                        SettingsItem(title: "Payment Deposits", icon: "banknote.fill", color: .green),
                        SettingsItem(title: "Forms", icon: "doc.text.fill", color: .blue),
                        SettingsItem(title: "Manage Subscription", icon: "crown.fill", color: .yellow)
                    ])
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
}

// MARK: - Settings Components
private struct SettingsSection: View {
    let title: String
    let items: [SettingsItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    SettingsRow(item: item, isLast: index == items.count - 1)
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

private struct SettingsItem {
    let title: String
    let icon: String
    let color: Color
}

private struct SettingsRow: View {
    let item: SettingsItem
    let isLast: Bool
    
    var body: some View {
        Button(action: {
            // Handle settings item tap
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.color.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(item.color)
                }
                
                // Title
                Text(item.title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
        }
        .buttonStyle(.plain)
        .overlay(
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5),
            alignment: isLast ? .top : .bottom
        )
    }
}

// MARK: - Image Picker
private struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

private struct WeeklyAvailability: Codable, Hashable {
    struct Day: Codable, Hashable { var enabled: Bool; var start: Date; var end: Date }
    var days: [Int: Day] // 1..7 (Mon..Sun per ISO)
}

private struct StudioInfo: Codable, Hashable { var name: String; var location: String }

private struct BookingSettings: Codable, Hashable {
    var links: [BookingLink]
    var availability: WeeklyAvailability
    var studio: StudioInfo
    var blackoutDates: Set<String> // yyyy-MM-dd
    var reminders24h: Bool
}

private final class BookingStore: ObservableObject {
    @Published var settings: BookingSettings
    private let key = "BookingSettings.v1"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(BookingSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = BookingStore.defaultSettings()
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func defaultSettings() -> BookingSettings {
        let calendar = Calendar(identifier: .iso8601)
        var days: [Int: WeeklyAvailability.Day] = [:]
        for i in 1...7 {
            let start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
            let end = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
            days[i] = WeeklyAvailability.Day(enabled: i <= 5, start: start, end: end)
        }
        let availability = WeeklyAvailability(days: days)
        let links = [
            BookingLink(title: "Reserva General", url: "https://example.com/reserva/general"),
            BookingLink(title: "Consulta Inicial", url: "https://example.com/reserva/consulta")
        ]
        let studio = StudioInfo(name: "Mi Estudio", location: "Calle Principal 123, Ciudad")
        return BookingSettings(links: links, availability: availability, studio: studio, blackoutDates: [], reminders24h: true)
    }
}

// MARK: - Blackout Range Model
private struct BlackoutRange {
    let startDate: Date
    let endDate: Date
    let isos: [String] // ISO date strings for this range
    
    var isSingleDay: Bool {
        Calendar.current.isDate(startDate, inSameDayAs: endDate)
    }
    
    var displayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("d 'de' MMMM")
        
        if isSingleDay {
            return formatter.string(from: startDate)
        } else {
            let startText = formatter.string(from: startDate)
            let endText = formatter.string(from: endDate)
            return "\(startText) - \(endText)"
        }
    }
}

private struct BookingSettingsPage: View {
    @StateObject private var store = BookingStore()
    @State private var newLinkTitle: String = ""
    @State private var newLinkURL: String = ""
    @State private var selectedBlackout: Date = Date()
    @State private var selectedBlackoutStart: Date = Date()
    @State private var selectedBlackoutEnd: Date = Date()
    @State private var showingEditModal = false
    @State private var editingLink: BookingLink?
    @State private var editLinkTitle: String = ""
    @State private var editLinkURL: String = ""
    
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
                    // Single day option
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
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    // Date range option
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
                    .padding(.vertical, 8)
                    
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
    }
    
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
    private func removeBlackout(_ iso: String) {
        store.settings.blackoutDates.remove(iso)
        store.save()
    }
    private func sortedBlackouts() -> [String] {
        store.settings.blackoutDates.sorted()
    }
    
    private func groupedBlackouts() -> [BlackoutRange] {
        let sortedDates = sortedBlackouts()
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
    private func humanReadable(_ iso: String) -> String {
        let f = DateFormatter(); f.calendar = Calendar(identifier: .iso8601); f.dateFormat = "yyyy-MM-dd"
        let out = DateFormatter(); out.locale = .current; out.setLocalizedDateFormatFromTemplate("EEEE, d 'de' MMMM, y")
        if let d = f.date(from: iso) { return out.string(from: d) }
        return iso
    }
    
    private func editLink(_ link: BookingLink) {
        editingLink = link
        editLinkTitle = link.title
        editLinkURL = link.url
        showingEditModal = true
    }
    
    private func copyLink(_ link: BookingLink) {
        UIPasteboard.general.string = link.url
        // You could add a toast notification here if needed
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
}

// MARK: - Booking Link Components
private struct BookingLinkCard: View {
    let link: BookingLink
    let onEdit: () -> Void
    let onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(link.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // URL (truncated)
            Text(link.url)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .truncationMode(.tail)
            
            // Action buttons
            HStack(spacing: 8) {
                Button("Copiar") {
                    onCopy()
                }
                .font(.caption)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor.opacity(0.1))
                )
                
                Spacer()
                
                Button("Editar") {
                    onEdit()
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.tertiarySystemBackground))
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EditBookingLinkModal: View {
    @Binding var link: BookingLink?
    @Binding var title: String
    @Binding var url: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Enlace")) {
                    TextField("Título", text: $title)
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section(footer: Text("El enlace será copiado al portapapeles cuando el usuario haga clic en 'Copiar'")) {
                    EmptyView()
                }
            }
            .navigationTitle("Editar Enlace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        onSave()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || url.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

private struct ChatBotPage: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .bot, text: "¡Hola! Soy tu asistente. ¿En qué te ayudo?", timestamp: Date())
    ]
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { msg in
                            ChatBubble(message: msg)
                                .id(msg.id)
                                .padding(.horizontal, 12)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            
            Divider()
            HStack(spacing: 8) {
                TextField("Escribe un mensaje...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button(action: send) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.all, 12)
            .background(.ultraThinMaterial)
        }
    }
    
    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        let user = ChatMessage(role: .user, text: text, timestamp: Date())
        messages.append(user)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let reply = botReply(to: text)
            messages.append(ChatMessage(role: .bot, text: reply, timestamp: Date()))
        }
    }
    
    private func botReply(to text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("hola") { return "¡Hola! 👋 ¿Qué te gustaría saber hoy?" }
        if lower.contains("calend") { return "Puedo ayudarte a ver eventos de tu calendario." }
        if lower.contains("ayuda") { return "Prueba con: ‘muestra mis eventos de hoy’ o ‘cambia a vista semanal’." }
        return "He recibido: \(text)"
    }
}

private struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .bot { spacer(leading: false) }
            VStack(alignment: .leading, spacing: 6) {
                Text(message.text)
                    .font(.body)
                    .padding(12)
                    .background(bubbleBackground)
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            if message.role == .user { spacer(leading: true) }
        }
    }
    
    private var bubbleBackground: some ShapeStyle {
        if message.role == .user {
            return AnyShapeStyle(Color.accentColor)
        } else {
            return AnyShapeStyle(Color(.secondarySystemBackground))
        }
    }
    
    @ViewBuilder
    private func spacer(leading: Bool) -> some View {
        if leading {
            Spacer(minLength: 48)
        } else {
            Spacer(minLength: 48)
        }
    }
}

// MARK: - Floating Tab Bar
private struct FloatingTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        HStack(spacing: 6) {
            tabButton(.one, emoji: "📆")
            tabButton(.two, emoji: "📖")
            tabButton(.three, emoji: "🤖")
            tabButton(.four, emoji: "⚙️")
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 0, x: 0, y: 6)
        )
    }
    
    private func tabButton(_ tab: ContentView.Tab, emoji: String) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 0) {
                Text(emoji)
                    .font(.system(size: 20))
            }
            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}



// MARK: - Safe area helpers
private var safeBottomPadding: CGFloat {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let inset = scene.windows.first?.safeAreaInsets.bottom else { return 4 }
    return max(4, inset + 2)
}
