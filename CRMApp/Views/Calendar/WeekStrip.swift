import SwiftUI

// MARK: - Week Strip
struct WeekStrip: View {
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
                        .notionText(size: .caption, color: .notionTextSecondary)
                    Text(dayNumber(for: day))
                        .notionText(size: .large, color: isSelected ? .notionBlue : .notionTextPrimary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.notionBlueLight : Color.clear)
                        )
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { selectedDate = day }
            }
        }
        .notionPadding(.vertical, .small)
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
