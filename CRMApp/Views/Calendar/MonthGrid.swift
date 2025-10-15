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
    
    // Compact responsive properties
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var cellSize: CGFloat {
        let padding: CGFloat = isIPad ? 80 : 40
        let spacing: CGFloat = isIPad ? 8 : 6
        let availableWidth = screenWidth - padding
        let cellWidth = (availableWidth - (spacing * 6)) / 7
        return max(isIPad ? 60 : 45, cellWidth)
    }
    
    private var cellHeight: CGFloat {
        isIPad ? 80 : 65
    }
    
    private var gridSpacing: CGFloat {
        isIPad ? 8 : 6
    }
    
    private var monthStart: Date {
        let comps = calendar.dateComponents([.year, .month], from: monthAnchor)
        return calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: 1)) ?? monthAnchor
    }
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
    }
    
    private var firstWeekdayOffset: Int {
        let weekday = calendar.component(.weekday, from: monthStart)
        let first = calendar.firstWeekday
        return (weekday - first + 7) % 7
    }
    
    private var monthDaysGrid: [Date] {
        var days: [Date] = []
        // Previous month padding
        if let prevStart = calendar.date(byAdding: .day, value: -firstWeekdayOffset, to: monthStart) {
            for i in 0..<(firstWeekdayOffset) {
                guard let d = calendar.date(byAdding: .day, value: i, to: prevStart) else { continue }
                days.append(d)
            }
        }
        // Current month
        for i in 0..<daysInMonth {
            guard let d = calendar.date(byAdding: .day, value: i, to: monthStart) else { continue }
            days.append(d)
        }
        // Next month padding to 6 weeks (42 cells)
        let remaining = max(0, 42 - days.count)
        if let last = days.last {
            for i in 1...remaining {
                guard let d = calendar.date(byAdding: .day, value: i, to: last) else { continue }
                days.append(d)
            }
        }
        return days
    }
    
    var body: some View {
        VStack(spacing: isIPad ? 16 : 12) {
            // Compact header
            monthHeader
            
            // Compact weekdays header
            weekdaysHeader
            
            // Compact calendar grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: 7),
                spacing: gridSpacing
            ) {
                ForEach(monthDaysGrid, id: \.self) { day in
                    dayCell(day)
                        .frame(height: cellHeight)
                }
            }
        }
        .modernPadding(.all, isIPad ? .large : .medium)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 20 : 16)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 20 : 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.borderSecondary,
                                    Color.borderLight
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: isIPad ? 12 : 8, x: 0, y: isIPad ? 4 : 2)
        )
    }
    
    private var monthHeader: some View {
        HStack {
            // Compact previous month button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    onMonthChanged(-1)
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: isIPad ? 16 : 14, weight: .semibold))
                    .foregroundColor(Color.textSecondary)
                    .frame(width: isIPad ? 36 : 32, height: isIPad ? 36 : 32)
                    .frame(minWidth: 44, minHeight: 44)
                    .background(
                        Circle()
                            .fill(Color.backgroundTertiary)
                            .overlay(
                                Circle()
                                    .stroke(Color.borderLight, lineWidth: 0.5)
                            )
                    )
            }
            .modernButton(style: .ghost)
            .accessibilityLabel("Mes anterior")
            .accessibilityHint("Navega al mes anterior en el calendario")
            
            Spacer()
            
            // Compact month and year title
            VStack(spacing: 2) {
                Text(monthTitle)
                    .modernText(size: isIPad ? .headline : .body, color: .textPrimary)
                    .fontWeight(.bold)
                
                Text(yearTitle)
                    .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Compact next month button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    onMonthChanged(1)
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: isIPad ? 16 : 14, weight: .semibold))
                    .foregroundColor(Color.textSecondary)
                    .frame(width: isIPad ? 36 : 32, height: isIPad ? 36 : 32)
                    .frame(minWidth: 44, minHeight: 44)
                    .background(
                        Circle()
                            .fill(Color.backgroundTertiary)
                            .overlay(
                                Circle()
                                    .stroke(Color.borderLight, lineWidth: 0.5)
                            )
                    )
            }
            .modernButton(style: .ghost)
            .accessibilityLabel("Mes siguiente")
            .accessibilityHint("Navega al mes siguiente en el calendario")
        }
        .modernPadding(.vertical, .small)
    }
    
    private var weekdaysHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let startIndex = calendar.firstWeekday - 1
        let ordered = Array(symbols[startIndex...] + symbols[..<startIndex])
        
        return HStack(spacing: gridSpacing) {
            ForEach(ordered, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .modernText(
                        size: isIPad ? .subhead : .caption,
                        color: .textTertiary
                    )
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .modernPadding(.vertical, .xsmall)
            }
        }
        .modernPadding(.bottom, .small)
    }
    
    private func dayCell(_ date: Date) -> some View {
        let isInCurrentMonth = calendar.isDate(date, equalTo: monthStart, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let dayEvents = eventsByDay[calendar.startOfDay(for: date)] ?? []
        let dayNumber = calendar.component(.day, from: date)

        return VStack(spacing: isIPad ? 4 : 3) {
            // Compact day number header
            HStack {
                Text("\(calendar.component(.day, from: date))")
                    .modernText(
                        size: isIPad ? .body : .subhead,
                        color: isInCurrentMonth ? 
                            (isToday ? .calendarToday : .textPrimary) : 
                            .textTertiary
                    )
                    .fontWeight(isToday || isSelected ? .bold : .semibold)
                Spacer()
            }
            .modernPadding(.horizontal, .xsmall)
            .modernPadding(.top, .xsmall)
            
            // Compact event previews
            VStack(spacing: isIPad ? 2 : 1) {
                if !dayEvents.isEmpty {
                    ForEach(Array(dayEvents.prefix(isIPad ? 2 : 1)), id: \.id) { event in
                        compactEventPreview(event)
                    }
                    if dayEvents.count > (isIPad ? 2 : 1) {
                        Text("+\(dayEvents.count - (isIPad ? 2 : 1))")
                            .modernText(
                                size: .small,
                                color: .textSecondary
                            )
                            .fontWeight(.semibold)
                            .modernPadding(.horizontal, .xsmall)
                            .modernPadding(.vertical, .xsmall)
                            .background(
                                Capsule()
                                    .fill(Color.backgroundTertiary)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.borderLight, lineWidth: 0.5)
                                    )
                            )
                    }
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modernPadding(.horizontal, .xsmall)
            .modernPadding(.bottom, .xsmall)
        }
        .frame(maxWidth: .infinity)
        .frame(minWidth: 44, minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                .fill(
                    isSelected ? 
                        LinearGradient(
                            colors: [
                                Color.calendarSelected.opacity(0.2),
                                Color.calendarSelected.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : 
                        LinearGradient(
                            colors: [Color.backgroundSecondary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                        .stroke(
                            isSelected ? Color.calendarSelected : Color.borderLight,
                            lineWidth: isSelected ? 2 : 0.5
                        )
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .shadow(
            color: isSelected ? Color.calendarSelected.opacity(0.2) : Color.black.opacity(0.02),
            radius: isSelected ? 8 : 2,
            x: 0,
            y: isSelected ? 4 : 1
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isToday)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDate = date
                onSelectDate(date)
            }
        }
        .accessibilityLabel("\(dayNumber) \(isToday ? "hoy" : "")")
        .accessibilityHint(dayEvents.isEmpty ? "Sin eventos" : "\(dayEvents.count) evento\(dayEvents.count == 1 ? "" : "s")")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
    
    private func compactEventPreview(_ event: MockEvent) -> some View {
        HStack(spacing: isIPad ? 4 : 3) {
            // Compact event indicator
            Circle()
                .fill(eventColor(for: event))
                .frame(width: isIPad ? 6 : 4, height: isIPad ? 6 : 4)
            
            Text(event.title)
                .modernText(
                    size: .small,
                    color: .textPrimary
                )
                .fontWeight(.medium)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
        }
        .modernPadding(.horizontal, .xsmall)
        .modernPadding(.vertical, .xsmall)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 6 : 4)
                .fill(eventColor(for: event).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 6 : 4)
                        .stroke(eventColor(for: event).opacity(0.3), lineWidth: 0.5)
                )
        )
    }
    
    private func eventColor(for event: MockEvent) -> Color {
        let colors: [Color] = [
            .calendarEventBlue,
            .calendarEventOrange,
            .calendarEventPurple,
            .calendarEventGreen,
            .calendarEventRed,
            .calendarEventTeal,
            .calendarEventPink,
            .calendarEventYellow
        ]
        let index = abs(event.title.hashValue) % colors.count
        return colors[index]
    }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter.string(from: monthAnchor).capitalized
    }
    
    private var yearTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("yyyy")
        return formatter.string(from: monthAnchor)
    }
}