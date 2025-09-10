import SwiftUI
import EventKit

struct ContentView: View {
    enum Tab: Int, CaseIterable { case one = 1, two = 2, three = 3, four = 4 }
    @State private var selectedTab: Tab = .one
    private let tabBarBottomInset: CGFloat = 88
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .one:
                    CalendarPage()
                case .two:
                    NumberedScreen(number: 2)
                case .three:
                    ChatBotPage()
                case .four:
                    NumberedScreen(number: 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .padding(.bottom, tabBarBottomInset)

            FloatingTabBar(selectedTab: $selectedTab)
                .frame(maxWidth: 360)
                .padding(.bottom, safeBottomPadding)
        }
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

// MARK: - Calendar (Tab 1)
private struct CalendarPage: View {
    @State private var selectedDate: Date = Date()
    @State private var events: [EKEvent] = []
    @State private var authorizationStatus: EKAuthorizationStatus = .notDetermined
    private let eventStore = EKEventStore()
    @State private var currentMonthAnchor: Date = Date()
    @State private var eventsCountByDay: [Date: Int] = [:] // keys are startOfDay
    
    private enum ViewMode: String, CaseIterable, Identifiable {
        case month = "Mes"
        case week = "Semana"
        case day = "Día"
        var id: String { rawValue }
    }
    @State private var viewMode: ViewMode = .month
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Vista", selection: $viewMode) {
                    ForEach(ViewMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Group {
                    switch viewMode {
                    case .month:
                        MonthGrid(
                            selectedDate: $selectedDate,
                            monthAnchor: $currentMonthAnchor,
                            eventsCountByDay: eventsCountByDay,
                            onMonthChanged: { delta in
                                currentMonthAnchor = Calendar.current.date(byAdding: .month, value: delta, to: currentMonthAnchor) ?? currentMonthAnchor
                                selectedDate = clampSelectedDateToMonth(selectedDate, monthAnchor: currentMonthAnchor)
                                loadMonthEvents()
                                loadEvents()
                            },
                            onSelectDate: { date in
                                selectedDate = date
                                loadEvents()
                            }
                        )
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 520)
                    case .week:
                        WeekStrip(selectedDate: $selectedDate)
                            .padding(.horizontal)
                            .onChange(of: selectedDate) { _, _ in loadEvents() }
                    case .day:
                        DayHeader(date: selectedDate)
                            .padding(.horizontal)
                    }
                }
                
                switch authorizationStatus {
                case .authorized, .fullAccess:
                    EventsList(events: events)
                        .overlay(Group { if events.isEmpty { Text("Sin eventos para esta fecha").foregroundColor(.secondary) } })
                case .denied, .restricted:
                    VStack(spacing: 8) {
                        Text("Permiso denegado para Calendario")
                            .font(.headline)
                        Text("Ve a Ajustes > Privacidad > Calendarios para conceder acceso.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Reintentar") { requestAccess() }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                default:
                    VStack(spacing: 8) {
                        Text("Se requiere acceso al Calendario")
                            .font(.headline)
                        Button("Conceder acceso") { requestAccess() }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Calendario")
            .task { await determineAuthorizationAndLoad() }
        }
    }
    
    private func determineAuthorization() -> EKAuthorizationStatus {
        if #available(iOS 17, *) {
            return EKEventStore.authorizationStatus(for: .event)
        } else {
            return EKEventStore.authorizationStatus(for: .event)
        }
    }
    
    private func requestAccess() {
        if #available(iOS 17, *) {
            eventStore.requestFullAccessToEvents { granted, _ in
                DispatchQueue.main.async {
                    authorizationStatus = granted ? .fullAccess : .denied
                    if granted { loadEvents() }
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, _ in
                DispatchQueue.main.async {
                    authorizationStatus = granted ? .authorized : .denied
                    if granted { loadEvents() }
                }
            }
        }
    }
    
    private func loadEvents() {
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        let predicate = eventStore.predicateForEvents(withStart: dayStart, end: dayEnd, calendars: nil)
        events = eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
    }

    private func loadMonthEvents() {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: currentMonthAnchor)
        guard let monthStart = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: 1)) else { return }
        let monthRange = cal.range(of: .day, in: .month, for: monthStart) ?? (1..<29)
        let lastDay = monthRange.count
        let monthEnd = cal.date(byAdding: DateComponents(day: lastDay, hour: 23, minute: 59, second: 59), to: monthStart) ?? monthStart
        let predicate = eventStore.predicateForEvents(withStart: monthStart, end: monthEnd, calendars: nil)
        let monthEvents = eventStore.events(matching: predicate)
        var counts: [Date: Int] = [:]
        for ev in monthEvents {
            let day = cal.startOfDay(for: ev.startDate)
            counts[day, default: 0] += 1
        }
        eventsCountByDay = counts
    }
    
    private func dateRangeString(for event: EKEvent) -> String {
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
    
    private func determineAuthorizationAndLoad() async {
        let status = determineAuthorization()
        await MainActor.run { authorizationStatus = status }
        switch status {
        case .authorized, .fullAccess:
            await MainActor.run {
                currentMonthAnchor = selectedDate
                loadMonthEvents()
                loadEvents()
            }
        case .notDetermined:
            requestAccess()
        default:
            break
        }
    }

    private func clampSelectedDateToMonth(_ date: Date, monthAnchor: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: monthAnchor)
        guard let monthStart = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: 1)) else { return date }
        let range = cal.range(of: .day, in: .month, for: monthStart) ?? (1..<29)
        let clampedDay = min(cal.component(.day, from: date), range.count)
        return cal.date(from: DateComponents(year: comps.year, month: comps.month, day: clampedDay)) ?? date
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
    let events: [EKEvent]
    var body: some View {
        List(events, id: \.eventIdentifier) { event in
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
    private func dateRangeString(for event: EKEvent) -> String {
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
        VStack(spacing: 12) {
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
            Text(formattedMonth(monthStart))
                .font(.title2).bold()
            Spacer()
            Button { onMonthChanged(1) } label: { Image(systemName: "chevron.right").font(.headline) }
        }
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
        let count = eventsCountByDay[calendar.startOfDay(for: date)] ?? 0
        return VStack(spacing: 4) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 36, height: 32)
                }
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .bold : .regular))
                    .foregroundColor(isInCurrentMonth ? (isSelected ? .accentColor : .primary) : .secondary)
                    .overlay(
                        Group {
                            if isToday && !isSelected {
                                Circle()
                                    .stroke(Color.accentColor, lineWidth: 1)
                                    .frame(width: 26, height: 26)
                            }
                        }
                    )
            }
            eventDots(count: count)
        }
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedDate = date
            onSelectDate(date)
        }
    }
    
    @ViewBuilder
    private func eventDots(count: Int) -> some View {
        if count > 0 {
            HStack(spacing: 2) {
                ForEach(0..<min(count, 3), id: \.self) { _ in
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 4, height: 4)
                }
            }
        } else {
            Color.clear.frame(height: 4)
        }
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
        .navigationTitle("Chatbot")
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
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .frame(height: 52)
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
                    .font(.system(size: 22))
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
          let inset = scene.windows.first?.safeAreaInsets.bottom else { return 16 }
    return max(16, inset + 8)
}
