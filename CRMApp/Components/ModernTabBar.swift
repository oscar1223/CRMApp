import SwiftUI

// MARK: - Modern Tab Bar
struct ModernTabBar: View {
    @Binding var selectedTab: AppTab
    
    // Compact responsive properties
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var responsiveIconSize: CGFloat {
        isIPad ? 20 : 18
    }
    
    private var responsiveCircleSize: CGFloat {
        isIPad ? 40 : 36
    }
    
    private var responsivePadding: CGFloat {
        isIPad ? 16 : 12
    }
    
    private var responsiveCornerRadius: CGFloat {
        isIPad ? 24 : 20
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, responsivePadding + 4)
        .padding(.vertical, responsivePadding)
        .background(
            RoundedRectangle(cornerRadius: responsiveCornerRadius)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: responsiveCornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.borderSecondary,
                                    Color.borderLight
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
    }
    
    private func tabButton(for tab: AppTab) -> some View {
        Button(action: { 
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: isIPad ? 4 : 3) {
                ZStack {
                    // Compact background circle
                    Circle()
                        .fill(
                            selectedTab == tab ? 
                                LinearGradient(
                                    colors: [
                                        Color.brandPrimary,
                                        Color.brandPrimary.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    colors: [Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .frame(width: responsiveCircleSize, height: responsiveCircleSize)
                        .scaleEffect(selectedTab == tab ? 1.0 : 0.8)
                        .shadow(
                            color: selectedTab == tab ? Color.brandPrimary.opacity(0.2) : Color.clear,
                            radius: selectedTab == tab ? 6 : 0,
                            x: 0,
                            y: selectedTab == tab ? 3 : 0
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    selectedTab == tab ? Color.clear : Color.borderLight,
                                    lineWidth: selectedTab == tab ? 0 : 0.5
                                )
                        )
                    
                    // Compact emoji icon
                    Text(tab.emoji)
                        .font(.system(size: responsiveIconSize))
                        .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab == tab)
                }
                
                // Compact text label
                Text(tab.title)
                    .font(.system(
                        size: isIPad ? 11 : 9,
                        weight: selectedTab == tab ? .semibold : .medium,
                        design: .rounded
                    ))
                    .foregroundColor(
                        selectedTab == tab ? Color.brandPrimary : Color.textSecondary
                    )
                    .opacity(selectedTab == tab ? 1.0 : 0.7)
                    .scaleEffect(selectedTab == tab ? 1.0 : 0.95)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
    }
}