import SwiftUI

// MARK: - Modern Design System
extension Color {
    // Primary Brand Colors
    static let brandPrimary = Color(red: 0.36, green: 0.32, blue: 0.98) // #5B51FA (Purple-Blue)
    static let brandSecondary = Color(red: 0.15, green: 0.15, blue: 0.15) // #262626 (Dark)
    static let brandAccent = Color(red: 1.0, green: 0.41, blue: 0.38) // #FF6A61 (Coral)
    
    // Background Colors
    static let backgroundPrimary = Color(red: 0.98, green: 0.98, blue: 0.99) // #FBFBFC
    static let backgroundSecondary = Color.white
    static let backgroundTertiary = Color(red: 0.96, green: 0.97, blue: 0.98) // #F5F6F7
    static let backgroundCard = Color.white
    static let backgroundDark = Color(red: 0.09, green: 0.09, blue: 0.11) // #171719
    static let backgroundDarkCard = Color(red: 0.13, green: 0.13, blue: 0.15) // #212125
    
    // Text Colors
    static let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.13) // #1C1C21
    static let textSecondary = Color(red: 0.44, green: 0.44, blue: 0.48) // #71717A
    static let textTertiary = Color(red: 0.64, green: 0.64, blue: 0.68) // #A3A3AD
    static let textInverse = Color.white
    
    // Calendar Specific Colors - Enhanced for better contrast
    static let calendarToday = Color(red: 0.36, green: 0.32, blue: 0.98) // #5B51FA
    static let calendarSelected = Color(red: 0.36, green: 0.32, blue: 0.98) // #5B51FA
    
    // Enhanced Event Colors with better contrast and vibrancy
    static let calendarEventOrange = Color(red: 1.0, green: 0.55, blue: 0.2) // #FF8C33 (More vibrant)
    static let calendarEventBlue = Color(red: 0.2, green: 0.7, blue: 1.0) // #33B3FF (More vibrant)
    static let calendarEventPurple = Color(red: 0.7, green: 0.2, blue: 1.0) // #B333FF (More vibrant)
    static let calendarEventGreen = Color(red: 0.2, green: 0.8, blue: 0.4) // #33CC66 (More vibrant)
    
    // Additional vibrant event colors
    static let calendarEventRed = Color(red: 1.0, green: 0.3, blue: 0.3) // #FF4D4D
    static let calendarEventTeal = Color(red: 0.2, green: 0.8, blue: 0.8) // #33CCCC
    static let calendarEventPink = Color(red: 1.0, green: 0.4, blue: 0.8) // #FF66CC
    static let calendarEventYellow = Color(red: 1.0, green: 0.8, blue: 0.2) // #FFCC33
    
    // Status Colors
    static let successGreen = Color(red: 0.13, green: 0.7, blue: 0.4) // #22B366
    static let warningOrange = Color(red: 1.0, green: 0.67, blue: 0.0) // #FFAB00
    static let errorRed = Color(red: 0.93, green: 0.27, blue: 0.27) // #EE4545
    
    // Border Colors
    static let borderPrimary = Color(red: 0.89, green: 0.89, blue: 0.91) // #E4E4E7
    static let borderSecondary = Color(red: 0.93, green: 0.93, blue: 0.95) // #EDEDF2
    static let borderLight = Color(red: 0.96, green: 0.96, blue: 0.97) // #F4F4F6
}

// MARK: - Responsive Helper Functions
private func isIPad() -> Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

private func screenWidth() -> CGFloat {
    UIScreen.main.bounds.width
}

private func responsiveScaleFactor() -> CGFloat {
    if isIPad() {
        return 1.1      // Reduced from 1.4
    } else if screenWidth() > 414 {
        return 1.0      // Reduced from 1.1
    } else {
        return 1.0
    }
}

// MARK: - Modern Style Modifiers
extension View {
    // Responsive Modern Button Styles
    func modernButton(style: ModernButtonStyle = .primary) -> some View {
        let scaleFactor = responsiveScaleFactor()
        return self
            .font(.system(size: 13 * scaleFactor, weight: .medium))  // Reduced from 15
            .foregroundColor(style.textColor)
            .padding(.horizontal, 16 * scaleFactor)  // Reduced from 20
            .padding(.vertical, 10 * scaleFactor)   // Reduced from 12
            .background(
                RoundedRectangle(cornerRadius: 10 * scaleFactor)  // Reduced from 12
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10 * scaleFactor)  // Reduced from 12
                            .stroke(style.borderColor, lineWidth: style.borderWidth)
                    )
            )
            .shadow(color: style.shadowColor, radius: style.shadowRadius * scaleFactor, x: 0, y: style.shadowY * scaleFactor)
    }
    
    // Responsive Modern Card Style
    func modernCard(isDark: Bool = false) -> some View {
        let scaleFactor = responsiveScaleFactor()
        return self
            .padding(20 * scaleFactor)
            .background(
                RoundedRectangle(cornerRadius: 16 * scaleFactor)
                    .fill(isDark ? Color.backgroundDarkCard : Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16 * scaleFactor)
                            .stroke(Color.borderSecondary, lineWidth: 0.5)
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12 * scaleFactor, x: 0, y: 4 * scaleFactor)
    }
    
    // Responsive Modern Calendar Card Style
    func modernCalendarCard(isDark: Bool = false) -> some View {
        let scaleFactor = responsiveScaleFactor()
        return self
            .padding(16 * scaleFactor)
            .background(
                RoundedRectangle(cornerRadius: 20 * scaleFactor)
                    .fill(isDark ? Color.backgroundDark : Color.backgroundCard)
                    .shadow(color: Color.black.opacity(0.08), radius: 16 * scaleFactor, x: 0, y: 6 * scaleFactor)
            )
    }
    
    // Modern Input Style
    func modernInput() -> some View {
        let scaleFactor = responsiveScaleFactor()
        return self
            .font(.system(size: 13 * scaleFactor))  // Reduced from 15
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 14 * scaleFactor)  // Reduced from 16
            .padding(.vertical, 10 * scaleFactor)   // Reduced from 12
            .background(
                RoundedRectangle(cornerRadius: 10 * scaleFactor)  // Reduced from 12
                    .fill(Color.backgroundTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10 * scaleFactor)  // Reduced from 12
                            .stroke(Color.borderPrimary, lineWidth: 1)
                    )
            )
    }
    
    // Responsive Modern Typography
    func modernText(size: ModernTextSize = .body, color: Color = .textPrimary, weight: Font.Weight? = nil) -> some View {
        let scaleFactor = responsiveScaleFactor()
        return self
            .font(.system(size: size.size * scaleFactor, weight: weight ?? size.weight, design: .rounded))
            .foregroundColor(color)
    }
    
    // Responsive Modern Spacing
    func modernPadding(_ edges: Edge.Set = .all, _ length: ModernSpacing = .medium) -> some View {
        let scaleFactor = responsiveScaleFactor()
        return self.padding(edges, length.value * scaleFactor)
    }
}

// MARK: - Modern Design Tokens
enum ModernButtonStyle {
    case primary, secondary, ghost, danger, calendar
    
    var backgroundColor: Color {
        switch self {
        case .primary: return .brandPrimary
        case .secondary: return .backgroundCard
        case .ghost: return .clear
        case .danger: return .errorRed
        case .calendar: return .calendarSelected
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary: return .textInverse
        case .secondary: return .textPrimary
        case .ghost: return .textSecondary
        case .danger: return .textInverse
        case .calendar: return .textInverse
        }
    }
    
    var borderColor: Color {
        switch self {
        case .primary: return .clear
        case .secondary: return .borderPrimary
        case .ghost: return .clear
        case .danger: return .clear
        case .calendar: return .clear
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .primary: return 0
        case .secondary: return 1
        case .ghost: return 0
        case .danger: return 0
        case .calendar: return 0
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary: return .brandPrimary.opacity(0.25)
        case .secondary: return .clear
        case .ghost: return .clear
        case .danger: return .errorRed.opacity(0.25)
        case .calendar: return .calendarSelected.opacity(0.25)
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .primary: return 8
        case .secondary: return 0
        case .ghost: return 0
        case .danger: return 8
        case .calendar: return 8
        }
    }
    
    var shadowY: CGFloat {
        switch self {
        case .primary: return 4
        case .secondary: return 0
        case .ghost: return 0
        case .danger: return 4
        case .calendar: return 4
        }
    }
}

enum ModernTextSize {
    case title, headline, body, subhead, caption, small
    
    var size: CGFloat {
        switch self {
        case .title: return 22      // Reduced from 28
        case .headline: return 16   // Reduced from 20
        case .body: return 14        // Reduced from 16
        case .subhead: return 12     // Reduced from 14
        case .caption: return 10     // Reduced from 12
        case .small: return 8        // Reduced from 10
        }
    }
    
    var weight: Font.Weight {
        switch self {
        case .title: return .bold
        case .headline: return .semibold
        case .body: return .regular
        case .subhead: return .medium
        case .caption: return .regular
        case .small: return .regular
        }
    }
}

enum ModernSpacing {
    case xsmall, small, medium, large, xlarge, xxlarge

    var value: CGFloat {
        switch self {
        case .xsmall: return 4
        case .small: return 8
        case .medium: return 16
        case .large: return 24
        case .xlarge: return 32
        case .xxlarge: return 48
        }
    }
}

// MARK: - Device Helpers
extension UIDevice {
    static var isIPad: Bool {
        current.userInterfaceIdiom == .pad
    }

    static var isIPhone: Bool {
        current.userInterfaceIdiom == .phone
    }
}

// MARK: - View Extensions for Studio
extension View {
    /// Apply the standard studio background gradient
    func studioBackground() -> some View {
        self.background(
            LinearGradient(
                colors: [
                    Color.backgroundPrimary,
                    Color.backgroundTertiary,
                    Color.brandPrimary.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    /// Apply a content card with safe area bottom padding
    func contentCard(bottomPadding: CGFloat = 100) -> some View {
        self.padding(.bottom, bottomPadding)
    }
}

// MARK: - Status Color Extensions
extension ArtistStatus {
    var colorValue: Color {
        switch self {
        case .active: return .successGreen
        case .inactive: return .textTertiary
        case .vacation: return .warningOrange
        }
    }
}

extension AppointmentStatus {
    var colorValue: Color {
        switch self {
        case .pending: return .warningOrange
        case .confirmed: return .brandPrimary
        case .inProgress: return .calendarEventBlue
        case .completed: return .successGreen
        case .cancelled: return .textTertiary
        case .noShow: return .errorRed
        }
    }
}