import SwiftUI

// MARK: - App Tab Bar (inspired by reference screenshots)
struct AppTabBar: View {
    @Binding var selectedTab: AppTab
    var avatarImage: Image? = nil
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var barCornerRadius: CGFloat { isIPad ? 28 : 22 }
    private var barVerticalPadding: CGFloat { isIPad ? 18 : 14 }
    private var iconSize: CGFloat { isIPad ? 22 : 18 }
    private var avatarSize: CGFloat { isIPad ? 32 : 28 }
    
    var body: some View {
        HStack(spacing: isIPad ? 28 : 22) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    systemIconName: tab.systemIconName,
                    iconSize: iconSize,
                    avatarImage: tab == .settings ? avatarImage : nil,
                    avatarSize: avatarSize
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        selectedTab = tab
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, isIPad ? 18 : 16)
        .padding(.vertical, barVerticalPadding)
        .background(
            RoundedRectangle(cornerRadius: barCornerRadius, style: .continuous)
                .fill(Color.brandSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: barCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 18, x: 0, y: 8)
        )
        .padding(.horizontal, isIPad ? 28 : 20)
    }
}

// MARK: - Single Tab Item
private struct TabItem: View {
    let tab: AppTab
    let isSelected: Bool
    let systemIconName: String
    let iconSize: CGFloat
    let avatarImage: Image?
    let avatarSize: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if tab == .settings, let avatarImage {
                    avatarImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: avatarSize, height: avatarSize)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.white.opacity(0.6), lineWidth: isSelected ? 2 : 1)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isSelected)
                } else {
                    Image(systemName: systemIconName)
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundColor(Color.white.opacity(isSelected ? 1.0 : 0.7))
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                        .shadow(color: .black.opacity(0.2), radius: isSelected ? 6 : 0, x: 0, y: isSelected ? 2 : 0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isSelected)
                }
            }
            .frame(height: avatarSize)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
    }
}


