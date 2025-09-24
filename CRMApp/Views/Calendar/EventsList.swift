import SwiftUI

// MARK: - Events List
struct EventsList: View {
    let events: [MockEvent]
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: isIPad ? 8 : 6) {  // Reduced spacing for more compact layout
                ForEach(events, id: \.id) { event in
                    compactEventCard(event)
                }
            }
            .modernPadding(.horizontal, .small)
            .modernPadding(.vertical, .small)
        }
    }
    
    private func compactEventCard(_ event: MockEvent) -> some View {
        HStack(spacing: isIPad ? 12 : 10) {
            // Compact time indicator
            VStack(spacing: 2) {
                Circle()
                    .fill(eventColor(for: event))
                    .frame(width: isIPad ? 8 : 6, height: isIPad ? 8 : 6)
                    .shadow(color: eventColor(for: event).opacity(0.3), radius: 2, x: 0, y: 1)
                
                Rectangle()
                    .fill(eventColor(for: event).opacity(0.3))
                    .frame(width: isIPad ? 2 : 1.5)
                    .frame(maxHeight: .infinity)
                    .clipShape(Capsule())
            }
            .frame(height: isIPad ? 40 : 32)
            
            // Compact event details
            VStack(alignment: .leading, spacing: isIPad ? 4 : 3) {
                Text(event.title)
                    .modernText(size: isIPad ? .subhead : .caption, color: .textPrimary)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                HStack(spacing: isIPad ? 6 : 4) {
                    Image(systemName: "clock")
                        .font(.system(size: isIPad ? 10 : 9, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                    
                    Text(dateRangeString(for: event))
                        .modernText(size: isIPad ? .caption : .small, color: .textSecondary)
                }
            }
            
            Spacer()
            
            // Compact menu button
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: isIPad ? 12 : 10, weight: .medium))
                    .foregroundColor(Color.textTertiary)
            }
        }
        .modernPadding(.all, isIPad ? .small : .xsmall)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                .fill(Color.backgroundCard)
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
        .overlay(
            // Left accent border
            RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                .fill(eventColor(for: event))
                .frame(width: isIPad ? 3 : 2)
                .offset(x: isIPad ? -8 : -6),
            alignment: .leading
        )
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle event tap
        }
    }
    
    private func modernEventCard(_ event: MockEvent) -> some View {
        HStack(spacing: isIPad ? 20 : 16) {  // Increased spacing for iPad
            // Modern time indicator with enhanced styling
            VStack(spacing: isIPad ? 6 : 4) {
                Circle()
                    .fill(eventColor(for: event))
                    .frame(width: isIPad ? 12 : 10, height: isIPad ? 12 : 10)
                    .shadow(color: eventColor(for: event).opacity(0.4), radius: 4, x: 0, y: 2)
                
                Rectangle()
                    .fill(eventColor(for: event).opacity(0.4))
                    .frame(width: isIPad ? 3 : 2)
                    .frame(maxHeight: .infinity)
                    .clipShape(Capsule())
            }
            .frame(height: isIPad ? 64 : 48)
            
            // Event details with modern typography
            VStack(alignment: .leading, spacing: isIPad ? 12 : 8) {
                Text(event.title)
                    .modernText(size: isIPad ? .headline : .subhead, color: .textPrimary)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                HStack(spacing: isIPad ? 10 : 8) {
                    Image(systemName: "clock")
                        .font(.system(size: isIPad ? 12 : 11, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                    
                    Text(dateRangeString(for: event))
                        .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
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
        .modernPadding(.all, isIPad ? .medium : .small)  // Reduce overall padding
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 16 : 12)  // Slightly smaller card
                .fill(Color.backgroundCard)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
        .overlay(
            // Left accent border
            RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                .fill(eventColor(for: event))
                .frame(width: isIPad ? 4 : 3)
                .offset(x: isIPad ? -12 : -10),
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