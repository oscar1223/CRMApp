import SwiftUI

struct CalendarTabView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonthAnchor: Date
    @Binding var viewMode: CalendarPage.ViewMode
    @Binding var eventsCountByDay: [Date: Int]
    @Binding var eventsByDay: [Date: [MockEvent]]
    
    var body: some View {
        VStack(spacing: 40) {
            // Notion-style header
            HStack {
                Text(currentPageTitle)
                    .notionText(size: .large, color: .notionTextPrimary)
                
                Spacer()
                
                // Notion-style buttons
                HStack(spacing: 8) {
                    // Add event button
                    Button(action: {
                        addNewEvent()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .medium))
                            Text("Nuevo")
                                .notionText(size: .body)
                        }
                    }
                    .notionButton(style: .primary)
                    
                    // View mode toggle button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            cycleCalendarViewMode()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(viewMode.rawValue)
                                .notionText(size: .body)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .notionButton(style: .secondary)
                }
            }
            .notionPadding(.horizontal, .large)
            .notionPadding(.bottom, .medium)
            
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
