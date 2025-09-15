import SwiftUI

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
        VStack(spacing: 0) {
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
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDate = date
                            }
                        }
                    )
                    .notionCard()
                    .notionPadding(.horizontal, .large)
                    .notionPadding(.top, .small)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                case .week:
                    WeekStrip(selectedDate: $selectedDate)
                        .notionCard()
                        .notionPadding(.horizontal, .large)
                }
            }
            
            // Notion-style events section
            if !getEventsForSelectedDate().isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Eventos de \(formattedSelectedDate)")
                            .notionText(size: .large, color: .notionTextPrimary)
                        Spacer()
                    }
                    .notionPadding(.horizontal, .large)
                    .notionPadding(.top, .medium)
                    
                    EventsList(events: getEventsForSelectedDate())
                        .frame(maxHeight: 200)
                }
                .notionCard()
                .notionPadding(.horizontal, .large)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                // Notion-style empty state
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(.notionTextTertiary)
                    Text("Sin eventos para \(formattedSelectedDate)")
                        .notionText(size: .body, color: .notionTextSecondary)
                }
                .notionPadding(.vertical, .large)
                .frame(maxWidth: .infinity)
                .notionCard()
                .notionPadding(.horizontal, .large)
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
