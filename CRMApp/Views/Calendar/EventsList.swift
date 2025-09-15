import SwiftUI

// MARK: - Events List
struct EventsList: View {
    let events: [MockEvent]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(events, id: \.id) { event in
                    modernEventCard(event)
                }
            }
            .modernPadding(.horizontal, .medium)
            .modernPadding(.vertical, .medium)
        }
    }
    
    private func modernEventCard(_ event: MockEvent) -> some View {
        HStack(spacing: 16) {
            // Modern time indicator with enhanced styling
            VStack(spacing: 6) {
                Circle()
                    .fill(eventColor(for: event))
                    .frame(width: 12, height: 12)
                    .shadow(color: eventColor(for: event).opacity(0.4), radius: 4, x: 0, y: 2)
                
                Rectangle()
                    .fill(eventColor(for: event).opacity(0.4))
                    .frame(width: 3)
                    .frame(maxHeight: .infinity)
                    .clipShape(Capsule())
            }
            .frame(height: 60)
            
            // Event details with modern typography
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .modernText(size: .body, color: .textPrimary)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                    
                    Text(dateRangeString(for: event))
                        .modernText(size: .subhead, color: .textSecondary)
                }
                
                // Event category tag
                HStack {
                    Text("Trabajo")
                        .modernText(size: .caption, color: eventColor(for: event))
                        .fontWeight(.medium)
                        .modernPadding(.horizontal, .small)
                        .modernPadding(.vertical, .xsmall)
                        .background(
                            Capsule()
                                .fill(eventColor(for: event).opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(eventColor(for: event).opacity(0.3), lineWidth: 0.5)
                                )
                        )
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.textTertiary)
                    }
                }
            }
            
            Spacer()
        }
        .modernPadding(.all, .medium)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backgroundCard)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
        .overlay(
            // Left accent border
            RoundedRectangle(cornerRadius: 16)
                .fill(eventColor(for: event))
                .frame(width: 4)
                .offset(x: -12),
            alignment: .leading
        )
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle event tap
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: false)
    }
    
    private func eventColor(for event: MockEvent) -> Color {
        // Rotate through modern calendar colors based on event title hash
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