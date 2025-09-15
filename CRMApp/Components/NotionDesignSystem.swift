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
    
    // Calendar Specific Colors
    static let calendarToday = Color(red: 0.36, green: 0.32, blue: 0.98) // #5B51FA
    static let calendarSelected = Color(red: 0.36, green: 0.32, blue: 0.98) // #5B51FA
    static let calendarEventOrange = Color(red: 1.0, green: 0.67, blue: 0.36) // #FFAB5C
    static let calendarEventBlue = Color(red: 0.36, green: 0.78, blue: 1.0) // #5CC8FF
    static let calendarEventPurple = Color(red: 0.67, green: 0.36, blue: 1.0) // #AB5CFF
    static let calendarEventGreen = Color(red: 0.36, green: 0.9, blue: 0.67) // #5CE6AB
    
    // Status Colors
    static let successGreen = Color(red: 0.13, green: 0.7, blue: 0.4) // #22B366
    static let warningOrange = Color(red: 1.0, green: 0.67, blue: 0.0) // #FFAB00
    static let errorRed = Color(red: 0.93, green: 0.27, blue: 0.27) // #EE4545
    
    // Border Colors
    static let borderPrimary = Color(red: 0.89, green: 0.89, blue: 0.91) // #E4E4E7
    static let borderSecondary = Color(red: 0.93, green: 0.93, blue: 0.95) // #EDEDF2
    static let borderLight = Color(red: 0.96, green: 0.96, blue: 0.97) // #F4F4F6
}

// MARK: - Modern Style Modifiers
extension View {
    // Modern Button Styles
    func modernButton(style: ModernButtonStyle = .primary) -> some View {
        self
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(style.textColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style.borderColor, lineWidth: style.borderWidth)
                    )
            )
            .shadow(color: style.shadowColor, radius: style.shadowRadius, x: 0, y: style.shadowY)
    }
    
    // Modern Card Style
    func modernCard(isDark: Bool = false) -> some View {
        self
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDark ? Color.backgroundDarkCard : Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.borderSecondary, lineWidth: 0.5)
                    )
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
    
    // Modern Calendar Card Style
    func modernCalendarCard(isDark: Bool = false) -> some View {
        self
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isDark ? Color.backgroundDark : Color.backgroundCard)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
    
    // Modern Input Style
    func modernInput() -> some View {
        self
            .font(.system(size: 15))
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.backgroundTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.borderPrimary, lineWidth: 1)
                    )
            )
    }
    
    // Modern Typography
    func modernText(size: ModernTextSize = .body, color: Color = .textPrimary, weight: Font.Weight? = nil) -> some View {
        self
            .font(.system(size: size.size, weight: weight ?? size.weight, design: .rounded))
            .foregroundColor(color)
    }
    
    // Modern Spacing
    func modernPadding(_ edges: Edge.Set = .all, _ length: ModernSpacing = .medium) -> some View {
        self.padding(edges, length.value)
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
        case .title: return 28
        case .headline: return 20
        case .body: return 16
        case .subhead: return 14
        case .caption: return 12
        case .small: return 10
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

