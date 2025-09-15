import SwiftUI

// MARK: - Week Strip
struct WeekStrip: View {
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    
    // Responsive properties
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var weekDays: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    var body: some View {
        VStack(spacing: isIPad ? 20 : 16) {
            // Enhanced week header
            HStack {
                Text("Vista Semanal")
                    .modernText(size: isIPad ? .headline : .body, color: .textPrimary)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(weekRangeString)
                    .modernText(size: isIPad ? .body : .subhead, color: .textSecondary)
                    .fontWeight(.medium)
            }
            .modernPadding(.horizontal, .large)
            .modernPadding(.vertical, .medium)
            
            // Enhanced week days with better animations
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: isIPad ? 16 : 12) {
                    ForEach(weekDays, id: \.self) { day in
                        weekDayCard(day)
                            .frame(width: isIPad ? 120 : 90)
                    }
                }
                .modernPadding(.horizontal, .large)
            }
        }
        .modernPadding(.vertical, .medium)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 24 : 20)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 24 : 20)
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
                .shadow(color: Color.black.opacity(0.08), radius: isIPad ? 16 : 12, x: 0, y: isIPad ? 6 : 4)
        )
    }
    
    private func weekDayCard(_ date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let dayNumber = calendar.component(.day, from: date)
        let weekdaySymbol = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
        
        return VStack(spacing: isIPad ? 12 : 8) {
            // Enhanced weekday label
            Text(weekdaySymbol.uppercased())
                .modernText(
                    size: isIPad ? .caption : .small,
                    color: .textTertiary
                )
                .fontWeight(.bold)
            
            // Enhanced day number with better visual hierarchy
            Text("\(dayNumber)")
                .modernText(
                    size: isIPad ? .headline : .body,
                    color: isToday ? .calendarToday : .textPrimary
                )
                .fontWeight(isToday || isSelected ? .bold : .semibold)
                .frame(width: isIPad ? 48 : 40, height: isIPad ? 48 : 40)
                .background(
                    Circle()
                        .fill(
                            isSelected ? 
                                LinearGradient(
                                    colors: [
                                        Color.calendarSelected,
                                        Color.calendarSelected.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                (isToday ? 
                                    LinearGradient(
                                        colors: [
                                            Color.calendarToday.opacity(0.2),
                                            Color.calendarToday.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) : 
                                    LinearGradient(
                                        colors: [Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.calendarSelected :
                                    (isToday ? Color.calendarToday : Color.borderLight),
                                    lineWidth: isSelected || isToday ? 2 : 0.5
                                )
                        )
                )
                .shadow(
                    color: isSelected ? Color.calendarSelected.opacity(0.3) : 
                           (isToday ? Color.calendarToday.opacity(0.2) : Color.black.opacity(0.02)),
                    radius: isSelected ? 8 : (isToday ? 6 : 2),
                    x: 0,
                    y: isSelected ? 4 : (isToday ? 3 : 1)
                )
                .scaleEffect(isSelected ? 1.1 : (isToday ? 1.05 : 1.0))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isToday)
        }
        .modernPadding(.vertical, .medium)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                .fill(
                    isSelected ? 
                        LinearGradient(
                            colors: [
                                Color.calendarSelected.opacity(0.1),
                                Color.calendarSelected.opacity(0.05)
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
                    RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                        .stroke(
                            isSelected ? Color.calendarSelected.opacity(0.3) : Color.borderLight,
                            lineWidth: isSelected ? 1 : 0.5
                        )
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDate = date
            }
        }
    }
    
    private var weekRangeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
        
        let startDay = weekDays.first ?? selectedDate
        let endDay = weekDays.last ?? selectedDate
        
        if calendar.isDate(startDay, equalTo: endDay, toGranularity: .month) {
            // Same month
            let startDayNumber = calendar.component(.day, from: startDay)
            let endDayNumber = calendar.component(.day, from: endDay)
            let monthName = formatter.string(from: startDay).components(separatedBy: " ").last ?? ""
            return "\(startDayNumber) - \(endDayNumber) \(monthName)"
        } else {
            // Different months
            let startString = formatter.string(from: startDay)
            let endString = formatter.string(from: endDay)
            return "\(startString) - \(endString)"
        }
    }
}