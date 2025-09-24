import SwiftUI

// MARK: - App Tab Enum
enum AppTab: Int, CaseIterable {
    case calendar = 1
    case booking = 2
    case chat = 3
    case settings = 4
    
    var title: String {
        switch self {
        case .calendar: return "Calendario"
        case .booking: return "Reservas"
        case .chat: return "Chat"
        case .settings: return "Ajustes"
        }
    }
    
    var emoji: String {
        switch self {
        case .calendar: return "📆"
        case .booking: return "📖"
        case .chat: return "🤖"
        case .settings: return "⚙️"
        }
    }

    // SF Symbols to support the new AppTabBar
    var systemIconName: String {
        switch self {
        case .calendar: return "calendar"
        case .booking: return "person.2"
        case .chat: return "list.bullet.rectangle"
        case .settings: return "person.crop.square"
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var selectedTab: AppTab = .calendar
    
    // Calendar state
    @State private var selectedDate: Date = Date()
    @State private var currentMonthAnchor: Date = Date()
    @State private var eventsCountByDay: [Date: Int] = [:]
    @State private var eventsByDay: [Date: [MockEvent]] = [:]
    
    // Responsive properties
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @State private var orientation: UIDeviceOrientation = .portrait
    
    private var isLandscape: Bool {
        orientation == .landscapeLeft || orientation == .landscapeRight
    }
    
    private var tabBarMaxWidth: CGFloat {
        if isIPad && isLandscape {
            return 600  // Wider for landscape iPad
        } else if isIPad {
            return 500
        } else {
            return 320
        }
    }
    
    // Responsive bottom padding based on orientation
    private var contentBottomPadding: CGFloat {
        if isIPad && isLandscape {
            return 80  // Less padding in landscape
        } else if isIPad {
            return 120
        } else {
            return 80
        }
    }
    
    var body: some View {
        ZStack {
            // Compact gradient background
            LinearGradient(
                colors: [
                    Color.backgroundPrimary,
                    Color.backgroundTertiary,
                    Color.backgroundSecondary.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                // Subtle background pattern for larger screens
                isIPad ? AnyView(
                    GeometryReader { geometry in
                        ZStack {
                            Circle()
                                .fill(Color.brandPrimary.opacity(0.02))
                                .frame(width: 200, height: 200)
                                .offset(x: geometry.size.width * 0.8, y: -geometry.size.height * 0.2)
                                .blur(radius: 40)
                        }
                    }
                ) : AnyView(EmptyView())
            )
            
            // Responsive main content container
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Responsive top spacing
                    Spacer()
                        .frame(height: responsiveTopSpacing)
                    
                    // Tab content with responsive design
                    Group {
                        switch selectedTab {
                        case .calendar:
                            CalendarMainView(
                                selectedDate: $selectedDate,
                                currentMonthAnchor: $currentMonthAnchor,
                                eventsCountByDay: $eventsCountByDay,
                                eventsByDay: $eventsByDay
                            )
                            .modernPadding(.horizontal, responsiveHorizontalPadding)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            
                        case .booking:
                            BookingMainView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            
                        case .chat:
                            ChatMainView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            
                        case .settings:
                            SettingsMainView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, contentBottomPadding)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
                }
            }
            
            // Compact floating tab bar (new style)
            VStack {
                Spacer()
                
                AppTabBar(selectedTab: $selectedTab)
                    .frame(maxWidth: tabBarMaxWidth)
                    .modernPadding(.bottom, .small)
                    .padding(.bottom, isIPad ? 0 : responsiveSafeBottomPadding)  // No bottom padding for iPad
            }
        }
        .onAppear {
            loadMockEvents()
            setupOrientationObserver()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
        .preferredColorScheme(.light)
        .background(Color.backgroundPrimary)
    }
    
    // Responsive spacing properties
    private var responsiveTopSpacing: CGFloat {
        if isIPad && isLandscape {
            return 8  // Minimal top spacing in landscape
        } else if isIPad {
            return 16
        } else {
            return 12
        }
    }
    
    private var responsiveHorizontalPadding: ModernSpacing {
        if isIPad && isLandscape {
            return .medium  // More padding in landscape
        } else if isIPad {
            return .small
        } else {
            return .xsmall
        }
    }
    
    // Minimal safe area padding for iPad
    private var responsiveSafeBottomPadding: CGFloat {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let inset = scene.windows.first?.safeAreaInsets.bottom else { 
            return isIPad ? 0.0 : 3.0  // Minimal padding for iPad
        }
        let basePadding: CGFloat = isIPad ? 0.0 : 3.0  // Minimal padding for iPad
        return max(basePadding, inset)  // Only use safe area inset if needed
    }
    
    private func setupOrientationObserver() {
        orientation = UIDevice.current.orientation
    }
    
    private func loadMockEvents() {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: currentMonthAnchor)
        guard let monthStart = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: 1)) else { return }
        
        // Create compact sample events
        var counts: [Date: Int] = [:]
        var eventsByDayDict: [Date: [MockEvent]] = [:]
        
        let sampleEvents = createSampleEvents(for: monthStart)
        
        for event in sampleEvents {
            let day = cal.startOfDay(for: event.startDate)
            counts[day, default: 0] += 1
            eventsByDayDict[day, default: []].append(event)
        }
        
        eventsCountByDay = counts
        eventsByDay = eventsByDayDict
    }
    
    private func createSampleEvents(for monthStart: Date) -> [MockEvent] {
        let cal = Calendar.current
        var events: [MockEvent] = []
        
        // Add compact sample events
        let eventTitles = [
            "Reunión",
            "Presentación",
            "Sesión",
            "Call",
            "Workshop",
            "Revisión",
            "Meeting",
            "Demo"
        ]
        
        for i in stride(from: 2, through: 28, by: 4) {
            if let day = cal.date(byAdding: .day, value: i, to: monthStart) {
                let titleIndex = i % eventTitles.count
                let startHour = 9 + (i % 6)
                let duration = 1 + (i % 2)
                
                events.append(MockEvent(
                    title: eventTitles[titleIndex],
                    startDate: cal.date(bySettingHour: startHour, minute: 0, second: 0, of: day) ?? day,
                    endDate: cal.date(bySettingHour: startHour + duration, minute: 0, second: 0, of: day) ?? day
                ))
                
                // Add some days with multiple events
                if i % 7 == 0 {
                    events.append(MockEvent(
                        title: "Seguimiento",
                        startDate: cal.date(bySettingHour: startHour + 2, minute: 30, second: 0, of: day) ?? day,
                        endDate: cal.date(bySettingHour: startHour + 3, minute: 0, second: 0, of: day) ?? day
                    ))
                }
            }
        }
        
        return events
    }
}

#Preview {
    ContentView()
}