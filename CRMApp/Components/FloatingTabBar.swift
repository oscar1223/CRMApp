import SwiftUI

// MARK: - Tab Enum
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
}

// MARK: - Modern Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .modernPadding(.vertical, .small)
        .modernPadding(.horizontal, .medium)
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
    }
    
    private func tabButton(_ tab: AppTab) -> some View {
        Button(action: { 
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab 
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(selectedTab == tab ? Color.brandPrimary : Color.clear)
                        .frame(width: 32, height: 32)
                        .scaleEffect(selectedTab == tab ? 1.0 : 0.8)
                    
                    Text(tab.emoji)
                        .font(.system(size: selectedTab == tab ? 18 : 16))
                        .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                }
                
                Text(tab.title)
                    .modernText(
                        size: .caption, 
                        color: selectedTab == tab ? .brandPrimary : .textSecondary,
                        weight: selectedTab == tab ? .semibold : .regular
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FloatingTabBar(selectedTab: .constant(.calendar))
}
