import SwiftUI

// MARK: - Events List
struct EventsList: View {
    let events: [MockEvent]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(events, id: \.id) { event in
                    HStack(spacing: 12) {
                        // Notion-style time indicator
                        VStack(spacing: 2) {
                            Circle()
                                .fill(Color.notionBlue)
                                .frame(width: 8, height: 8)
                            Rectangle()
                                .fill(Color.notionBlue.opacity(0.3))
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                        
                        // Event details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .notionText(size: .body, color: .notionTextPrimary)
                            Text(dateRangeString(for: event))
                                .notionText(size: .small, color: .notionTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .notionPadding(.horizontal, .medium)
                    .notionPadding(.vertical, .small)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.notionBackgroundSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.notionBorderLight, lineWidth: 1)
                            )
                    )
                }
            }
            .notionPadding(.horizontal, .medium)
            .notionPadding(.vertical, .small)
        }
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
