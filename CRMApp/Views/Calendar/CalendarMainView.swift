import SwiftUI

// MARK: - Calendar Main View
struct CalendarMainView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonthAnchor: Date
    @Binding var eventsCountByDay: [Date: Int]
    @Binding var eventsByDay: [Date: [MockEvent]]
    
    @State private var viewMode: ViewMode = .month
    @State private var showingNewActions: Bool = false
    @State private var editingEvent: MockEvent? = nil
    
    enum ViewMode: String, CaseIterable {
        case month = "Mes"
        case week = "Semana"
    }
    
    // Responsive properties
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @State private var orientation: UIDeviceOrientation = .portrait
    
    private var isLandscape: Bool {
        orientation == .landscapeLeft || orientation == .landscapeRight
    }
    
    var body: some View {
        GeometryReader { proxy in
            let isHorizontal = isIPad && proxy.size.width > proxy.size.height
            Group {
                if isHorizontal {
                    // Horizontal layout for iPad landscape (Calendar left, Events right)
                    horizontalLayout(width: proxy.size.width)
                } else {
                    // Vertical layout for portrait or iPhone
                    verticalLayout
                }
            }
        }
        .modernPadding(.bottom, .small)
        .onAppear {
            orientation = UIDevice.current.orientation
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
        .sheet(item: $editingEvent, onDismiss: {}) { event in
            EditEventSheet(
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay,
                onSave: { title, start, end, isAllDay in
                    update(event: event, title: title, start: start, end: end, isAllDay: isAllDay)
                },
                onDelete: { delete(event: event) }
            )
        }
    }
    
    private var calendarHeader: some View {
        VStack(spacing: isIPad ? 12 : 8) {
            // Compact main title
            HStack {
                VStack(alignment: .leading, spacing: isIPad ? 6 : 4) {
                    Text(currentPageTitle)
                        .modernText(size: isIPad ? .headline : .body, color: .textPrimary)
                        .fontWeight(.bold)
                    
                    Text(formattedCurrentDate)
                        .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Compact action buttons
                HStack(spacing: isIPad ? 12 : 8) {
                    Button(action: { showingNewActions = true }) {
                        HStack(spacing: isIPad ? 6 : 4) {
                            Image(systemName: "plus")
                                .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                            Text("Nuevo")
                                .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                        }
                    }
                    .modernButton(style: .primary)
                    
                    Button(action: { toggleViewMode() }) {
                        HStack(spacing: isIPad ? 4 : 3) {
                            Text(viewMode.rawValue)
                                .font(.system(size: isIPad ? 14 : 12, weight: .medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: isIPad ? 12 : 10, weight: .medium))
                                .rotationEffect(.degrees(viewMode == .month ? 0 : 180))
                        }
                    }
                    .modernButton(style: .secondary)
                }
            }
            .modernPadding(.horizontal, .medium)
            .modernPadding(.top, .small)
            
            // Compact selected date indicator
            selectedDateIndicator
        }
        .sheet(isPresented: $showingNewActions) {
            NewBookingActionsSheet(
                onCopyShortLink: { copyToPasteboard("https://ink.ly/racso") },
                onCopyFullLink: { copyToPasteboard("https://ink.ly/racso?utm=app&src=calendar") },
                onCreateNewLink: { /* navigate or placeholder */ },
                onAddManual: {
                    showingNewActions = false
                    addNewEvent()
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    private var selectedDateIndicator: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Fecha seleccionada")
                    .modernText(size: .small, color: .textTertiary)
                    .fontWeight(.medium)
                
                Text(formattedSelectedDate)
                    .modernText(size: isIPad ? .subhead : .caption, color: .brandPrimary)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            // Compact event count badge
            if !getEventsForSelectedDate().isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: isIPad ? 12 : 10, weight: .medium))
                        .foregroundColor(Color.brandPrimary)
                    
                    Text("\(getEventsForSelectedDate().count)")
                        .modernText(size: .small, color: .brandPrimary)
                        .fontWeight(.semibold)
                }
                .modernPadding(.horizontal, .small)
                .modernPadding(.vertical, .xsmall)
                .background(
                    Capsule()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(Color.brandPrimary.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .modernPadding(.horizontal, .medium)
        .modernPadding(.vertical, .small)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                .fill(Color.backgroundTertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 12 : 8)
                        .stroke(Color.borderLight, lineWidth: 0.5)
                )
        )
        .modernPadding(.horizontal, .medium)
    }
    
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: isIPad ? 12 : 8) {
            // Compact section header
            HStack {
                VStack(alignment: .leading, spacing: isIPad ? 4 : 2) {
                    Text("Eventos")
                        .modernText(size: isIPad ? .body : .subhead, color: .textPrimary)
                        .fontWeight(.bold)
                    
                    Text(formattedSelectedDate)
                        .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
                        .fontWeight(.medium)
                }
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: isIPad ? 4 : 3) {
                        Text("Ver todos")
                            .modernText(size: isIPad ? .subhead : .caption, color: .brandPrimary)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                            .font(.system(size: isIPad ? 12 : 10, weight: .semibold))
                            .foregroundColor(Color.brandPrimary)
                    }
                }
                .modernButton(style: .ghost)
            }
            .modernPadding(.horizontal, .medium)
            .modernPadding(.top, .small)
            
            // Responsive events list
            EventsList(events: getEventsForSelectedDate(), onSelect: { event in
                editingEvent = event
            })
                .frame(maxHeight: responsiveEventsMaxHeight)
                .background(
                    RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                        .fill(Color.backgroundSecondary)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                )
        }
        .modernCard()
        .modernPadding(.horizontal, .small)
    }
    
    private var currentPageTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return formatter.string(from: currentMonthAnchor).capitalized
    }
    
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("EEEE, d 'de' MMMM")
        return formatter.string(from: Date()).capitalized
    }
    
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("d 'de' MMMM")
        return formatter.string(from: selectedDate).capitalized
    }
    
    private func toggleViewMode() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewMode = viewMode == .month ? .week : .month
        }
    }
    
    private func addNewEvent() {
        let today = Date()
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
        let endTime = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: today) ?? today
        
        let newEvent = MockEvent(
            title: "Nueva Cita",
            startDate: startTime,
            endDate: endTime
        )
        
        let dayStart = calendar.startOfDay(for: today)
        eventsByDay[dayStart, default: []].append(newEvent)
        eventsCountByDay[dayStart, default: 0] += 1
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedDate = today
        }
    }

    private func copyToPasteboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    private func getEventsForSelectedDate() -> [MockEvent] {
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        return eventsByDay[dayStart] ?? []
    }

    private func update(event: MockEvent, title: String, start: Date, end: Date, isAllDay: Bool) {
        let cal = Calendar.current
        let oldDay = cal.startOfDay(for: event.startDate)
        if var arr = eventsByDay[oldDay] {
            arr.removeAll { $0.id == event.id }
            eventsByDay[oldDay] = arr
            eventsCountByDay[oldDay] = arr.count
        }
        var newEvent = MockEvent(title: title, startDate: start, endDate: end, isAllDay: isAllDay)
        newEvent.id = event.id
        let newDay = cal.startOfDay(for: start)
        eventsByDay[newDay, default: []].append(newEvent)
        eventsCountByDay[newDay] = eventsByDay[newDay]?.count ?? 0
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedDate = start
        }
    }

    private func delete(event: MockEvent) {
        let cal = Calendar.current
        let day = cal.startOfDay(for: event.startDate)
        if var arr = eventsByDay[day] {
            arr.removeAll { $0.id == event.id }
            eventsByDay[day] = arr
            eventsCountByDay[day] = arr.count
        }
    }
    
    private var responsiveSpacing: CGFloat {
        if isIPad && isLandscape {
            return 12  // Less spacing in landscape
        } else if isIPad {
            return 16
        } else {
            return 12
        }
    }
    
    private var responsiveEventsMaxHeight: CGFloat {
        if isIPad && isLandscape {
            return 320  // Compact height for 4-5 events in landscape
        } else if isIPad {
            return 240  // Compact height for portrait
        } else {
            return 160  // Compact height for iPhone
        }
    }
    
    // MARK: - Layout Views
    private var verticalLayout: some View {
        VStack(spacing: responsiveSpacing) {
            // Compact header
            calendarHeader
            
            // Calendar content with smoother transitions
            Group {
                switch viewMode {
                case .month:
                    MonthGrid(
                        selectedDate: $selectedDate,
                        monthAnchor: $currentMonthAnchor,
                        eventsCountByDay: eventsCountByDay,
                        eventsByDay: eventsByDay,
                        onMonthChanged: { delta in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentMonthAnchor = Calendar.current.date(byAdding: .month, value: delta, to: currentMonthAnchor) ?? currentMonthAnchor
                            }
                        },
                        onSelectDate: { date in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDate = date
                            }
                        }
                    )
                    .modernPadding(.horizontal, .small)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                case .week:
                    WeekStrip(selectedDate: $selectedDate)
                        .modernPadding(.horizontal, .small)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewMode)
            
            // Compact events section
            if !getEventsForSelectedDate().isEmpty {
                eventsSection
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: getEventsForSelectedDate().count)
            }
        }
    }
    
    private func horizontalLayout(width: CGFloat) -> some View {
        // 60/40 split between Calendar and Events
        let leftWidth = width * 0.6
        let rightWidth = width * 0.4
        return HStack(spacing: 20) {
            // Left side - Calendar
            VStack(spacing: 12) {
                // Compact header
                calendarHeader
                
                // Calendar content
                Group {
                    switch viewMode {
                    case .month:
                        MonthGrid(
                            selectedDate: $selectedDate,
                            monthAnchor: $currentMonthAnchor,
                            eventsCountByDay: eventsCountByDay,
                            eventsByDay: eventsByDay,
                            onMonthChanged: { delta in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    currentMonthAnchor = Calendar.current.date(byAdding: .month, value: delta, to: currentMonthAnchor) ?? currentMonthAnchor
                                }
                            },
                            onSelectDate: { date in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDate = date
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                    case .week:
                        WeekStrip(selectedDate: $selectedDate)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewMode)
            }
            .frame(width: leftWidth)
            
            // Right side - Events
            VStack(alignment: .leading, spacing: 12) {
                // Events header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Eventos")
                            .modernText(size: .headline, color: .textPrimary)
                            .fontWeight(.bold)
                        
                        Text(formattedSelectedDate)
                            .modernText(size: .subhead, color: .textSecondary)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("Ver todos")
                                .modernText(size: .subhead, color: .brandPrimary)
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.brandPrimary)
                        }
                    }
                    .modernButton(style: .ghost)
                }
                .modernPadding(.horizontal, .medium)
                .modernPadding(.top, .small)
                
                // Events list
                if !getEventsForSelectedDate().isEmpty {
                    EventsList(events: getEventsForSelectedDate(), onSelect: { event in
                        editingEvent = event
                    })
                        .frame(maxHeight: responsiveEventsMaxHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.backgroundSecondary)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        )
                        .modernCard()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: getEventsForSelectedDate().count)
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.textTertiary)
                        
                        Text("No hay eventos")
                            .modernText(size: .body, color: .textSecondary)
                            .fontWeight(.medium)
                        
                        Text("Selecciona una fecha para ver los eventos")
                            .modernText(size: .subhead, color: .textTertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.backgroundTertiary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.borderLight, lineWidth: 0.5)
                            )
                    )
                    .modernCard()
                }
            }
            .frame(width: rightWidth)
            .modernPadding(.leading, .medium)
        }
    }
}