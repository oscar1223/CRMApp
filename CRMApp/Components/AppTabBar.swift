import SwiftUI

// MARK: - App Tab Bar (inspired by reference screenshots)
struct AppTabBar: View {
    @Binding var selectedTab: AppTab
    var avatarImage: Image? = nil
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @State private var orientation: UIDeviceOrientation = .portrait
    
    private var isLandscape: Bool {
        orientation == .landscapeLeft || orientation == .landscapeRight
    }
    
    private var barCornerRadius: CGFloat { 
        if isIPad && isLandscape {
            return 24  // Smaller radius in landscape
        } else if isIPad {
            return 28
        } else {
            return 22
        }
    }
    
    private var barVerticalPadding: CGFloat { 
        if isIPad && isLandscape {
            return 10  // Less padding in landscape
        } else if isIPad {
            return 12
        } else {
            return 14
        }
    }
    
    private var iconSize: CGFloat { 
        if isIPad && isLandscape {
            return 20  // Smaller icons in landscape
        } else if isIPad {
            return 22
        } else {
            return 18
        }
    }
    
    private var avatarSize: CGFloat { 
        if isIPad && isLandscape {
            return 28  // Smaller avatar in landscape
        } else if isIPad {
            return 32
        } else {
            return 28
        }
    }
    
    var body: some View {
        HStack(spacing: responsiveTabSpacing) {
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
        .padding(.horizontal, responsiveHorizontalPadding)
        .padding(.vertical, barVerticalPadding)
        .background(
            RoundedRectangle(cornerRadius: barCornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: barCornerRadius, style: .continuous)
                        .fill(Color.brandSecondary.opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: barCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, responsiveOuterPadding)
        .padding(.bottom, isIPad ? 0 : 8)  // No bottom padding for iPad
        .onAppear {
            orientation = UIDevice.current.orientation
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
    }
    
    private var responsiveTabSpacing: CGFloat {
        if isIPad && isLandscape {
            return 32  // More spacing in landscape
        } else if isIPad {
            return 28
        } else {
            return 22
        }
    }
    
    private var responsiveHorizontalPadding: CGFloat {
        if isIPad && isLandscape {
            return 20  // More padding in landscape
        } else if isIPad {
            return 18
        } else {
            return 16
        }
    }
    
    private var responsiveOuterPadding: CGFloat {
        if isIPad && isLandscape {
            return 16  // More outer padding in landscape
        } else if isIPad {
            return 12
        } else {
            return 20
        }
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