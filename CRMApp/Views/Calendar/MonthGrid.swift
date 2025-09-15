import SwiftUI

// MARK: - Month Grid
struct MonthGrid: View {
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
        VStack(spacing: 12) {
            header
            weekdaysHeader
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
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
        .padding(.vertical, 8)
    }
    
    private var weekdaysHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let startIndex = calendar.firstWeekday - 1
        let ordered = Array(symbols[startIndex...] + symbols[..<startIndex])
        return HStack {
            ForEach(ordered, id: \.self) { s in
                Text(s.uppercased())
                    .notionText(size: .caption, color: .notionTextSecondary)
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
                    .notionText(size: .body, color: isInCurrentMonth ? (isToday ? .notionBlue : .notionTextPrimary) : .notionTextTertiary)
                Spacer()
            }
            .notionPadding(.horizontal, .small)
            .notionPadding(.top, .small)
            
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
        .frame(minHeight: 60, maxHeight: 100)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.notionBlueLight : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            isToday ? Color.notionBlue : Color.clear,
                            lineWidth: isToday ? 2 : 0
                        )
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = date
                onSelectDate(date)
            }
        }
    }
    
    private func eventPreview(_ event: MockEvent) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(Color.notionBlue)
                .frame(width: 4, height: 4)
            Text(event.title)
                .notionText(size: .caption, color: .notionTextPrimary)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer()
        }
        .notionPadding(.horizontal, .small)
        .notionPadding(.vertical, .small)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.notionBlueLight)
        )
    }
}
