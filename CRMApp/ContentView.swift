import SwiftUI
import SwiftData

// MARK: - App Tab Enum (Individual Mode)
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

// MARK: - Studio Tab Enum (Studio Mode)
enum StudioTab: Int, CaseIterable {
    case dashboard = 1
    case artists = 2
    case chat = 3
    case settings = 4

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .artists: return "Artistas"
        case .chat: return "Chat"
        case .settings: return "Ajustes"
        }
    }

    var systemIconName: String {
        switch self {
        case .dashboard: return "chart.bar.fill"
        case .artists: return "person.3.fill"
        case .chat: return "list.bullet.rectangle"
        case .settings: return "person.crop.square"
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.updatedAt, order: .reverse) private var profiles: [UserProfile]

    @State private var selectedTab: AppTab = .calendar
    @State private var selectedStudioTab: StudioTab = .dashboard
    @State private var isStudioMode: Bool = false // For hybrid mode toggle
    @State private var forceRefresh: Bool = false // Force UI refresh
    @State private var currentAccountType: AccountType = .individual
    
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
    
    private var currentProfile: UserProfile? {
        profiles.first
    }

    private var accountType: AccountType {
        currentProfile?.accountType ?? .individual
    }

    var body: some View {
        Group {
            // Hybrid mode: show toggle and render based on isStudioMode
            if currentAccountType == .hybrid {
                hybridModeView
            }
            // Studio mode: show studio interface
            else if currentAccountType == .studio {
                studioModeView
            }
            // Individual mode: show original interface
            else {
                individualModeView
            }
        }
        .id(currentAccountType.rawValue + (forceRefresh ? "refresh" : "")) // Force view refresh when account type changes
        .onAppear {
            loadMockEvents()
            setupOrientationObserver()
            updateCurrentAccountType()
            print("📱 ContentView appeared - Account Type: \(currentAccountType.displayName)")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AccountTypeChanged"))) { _ in
            print("🔔 AccountTypeChanged notification received")
            updateCurrentAccountType()
            forceRefresh.toggle()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
        .onChange(of: profiles.first?.accountType) { newValue in
            if let newType = newValue {
                print("🔄 Profile changed detected in @Query: \(newType.displayName)")
                currentAccountType = newType
            }
        }
        .onChange(of: profiles.count) { _ in
            print("👥 Profiles count changed: \(profiles.count)")
            updateCurrentAccountType()
        }
        .preferredColorScheme(.light)
        .background(Color.backgroundPrimary)
    }

    private func updateCurrentAccountType() {
        if let type = profiles.first?.accountType {
            currentAccountType = type
            print("🔄 Updated currentAccountType to: \(type.displayName)")
        }
    }

    // MARK: - Individual Mode View
    private var individualModeView: some View {
        ZStack {
            backgroundGradient

            // Responsive main content container
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: responsiveTopSpacing)

                    // Tab content
                    individualTabContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom, contentBottomPadding)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
                }
            }

            // Floating tab bar
            VStack {
                Spacer()
                AppTabBar(selectedTab: $selectedTab)
                    .frame(maxWidth: tabBarMaxWidth)
                    .modernPadding(.bottom, .small)
                    .padding(.bottom, isIPad ? 0 : responsiveSafeBottomPadding)
            }
        }
    }

    // MARK: - Studio Mode View
    private var studioModeView: some View {
        ZStack {
            backgroundGradient

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: responsiveTopSpacing)

                    // Studio tab content
                    studioTabContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom, contentBottomPadding)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedStudioTab)
                }
            }

            // Floating studio tab bar
            VStack {
                Spacer()
                StudioTabBar(selectedTab: $selectedStudioTab)
                    .frame(maxWidth: tabBarMaxWidth)
                    .modernPadding(.bottom, .small)
                    .padding(.bottom, isIPad ? 0 : responsiveSafeBottomPadding)
            }
        }
    }

    // MARK: - Hybrid Mode View
    private var hybridModeView: some View {
        ZStack {
            backgroundGradient

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Mode toggle at top
                    modeToggle
                        .modernPadding(.top, .small)
                        .modernPadding(.horizontal, .medium)

                    Spacer()
                        .frame(height: responsiveTopSpacing)

                    // Content based on mode
                    Group {
                        if isStudioMode {
                            studioTabContent
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else {
                            individualTabContent
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, contentBottomPadding)
                }
            }

            // Floating tab bar (switches based on mode)
            VStack {
                Spacer()
                if isStudioMode {
                    StudioTabBar(selectedTab: $selectedStudioTab)
                        .frame(maxWidth: tabBarMaxWidth)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    AppTabBar(selectedTab: $selectedTab)
                        .frame(maxWidth: tabBarMaxWidth)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                EmptyView()
                    .modernPadding(.bottom, .small)
                    .padding(.bottom, isIPad ? 0 : responsiveSafeBottomPadding)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isStudioMode)
        }
    }

    // MARK: - Mode Toggle (for hybrid)
    private var modeToggle: some View {
        HStack(spacing: 0) {
            // Individual button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isStudioMode = false
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                    Text("Personal")
                        .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                }
                .foregroundColor(isStudioMode ? .textSecondary : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, isIPad ? 10 : 8)
                .background(
                    RoundedRectangle(cornerRadius: isIPad ? 10 : 8)
                        .fill(isStudioMode ? Color.clear : Color.brandPrimary)
                )
            }

            // Studio button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isStudioMode = true
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                    Text("Estudio")
                        .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                }
                .foregroundColor(isStudioMode ? .white : .textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, isIPad ? 10 : 8)
                .background(
                    RoundedRectangle(cornerRadius: isIPad ? 10 : 8)
                        .fill(isStudioMode ? Color.brandPrimary : Color.clear)
                )
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 12 : 10)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 12 : 10)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        .frame(maxWidth: isIPad ? 300 : 240)
    }

    // MARK: - Background Gradient
    private var backgroundGradient: some View {
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
    }

    // MARK: - Individual Tab Content
    @ViewBuilder
    private var individualTabContent: some View {
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
    }

    // MARK: - Studio Tab Content
    @ViewBuilder
    private var studioTabContent: some View {
        Group {
            switch selectedStudioTab {
            case .dashboard:
                StudioDashboardView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .artists:
                ArtistsManagementView()
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