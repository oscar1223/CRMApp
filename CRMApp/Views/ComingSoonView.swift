import SwiftUI

// MARK: - Coming Soon View
struct ComingSoonView: View {
    let title: String
    let subtitle: String
    let emoji: String
    
    // Responsive properties
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var responsiveEmojiSize: CGFloat {
        isIPad ? 120 : 80
    }
    
    private var responsiveIconCircleSize: CGFloat {
        isIPad ? 200 : 160
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                // Modern icon with gradient background and enhanced styling
                ZStack {
                    // Outer glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.brandPrimary.opacity(0.15),
                                    Color.brandPrimary.opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: responsiveIconCircleSize + 40, height: responsiveIconCircleSize + 40)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: true)
                    
                    // Main icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.brandPrimary.opacity(0.12),
                                    Color.brandAccent.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: responsiveIconCircleSize, height: responsiveIconCircleSize)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.brandPrimary.opacity(0.3),
                                            Color.brandAccent.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color.brandPrimary.opacity(0.15), radius: 20, x: 0, y: 10)
                    
                    // Emoji icon
                    Text(emoji)
                        .font(.system(size: responsiveEmojiSize))
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: emoji)
                }
                .modernPadding(.bottom, .xxlarge)
                
                // Enhanced typography hierarchy
                VStack(spacing: 20) {
                    Text(title)
                        .modernText(size: .title, color: .textPrimary)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(subtitle)
                        .modernText(size: .body, color: .textSecondary)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .modernPadding(.horizontal, .xlarge)
                        .opacity(0.8)
                }
                .modernPadding(.bottom, .xxlarge)
                
                // Enhanced status badge with animation
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.warningOrange.opacity(0.2))
                            .frame(width: 16, height: 16)
                            .scaleEffect(1.5)
                            .opacity(0.6)
                            .animation(.easeInOut(duration: 1.5).repeatForever(), value: true)
                        
                        Circle()
                            .fill(Color.warningOrange)
                            .frame(width: 8, height: 8)
                    }
                    
                    Text("Próximamente")
                        .modernText(size: .subhead, color: .textSecondary)
                        .fontWeight(.semibold)
                }
                .modernPadding(.horizontal, .xlarge)
                .modernPadding(.vertical, .large)
                .background(
                    Capsule()
                        .fill(Color.backgroundTertiary)
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.borderSecondary,
                                            Color.borderLight
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                )
                .modernPadding(.bottom, .xlarge)
                
                // Enhanced description with better styling
                VStack(spacing: 12) {
                    Text("Esta función estará disponible")
                        .modernText(size: .subhead, color: .textTertiary)
                        .fontWeight(.medium)
                    
                    Text("en una próxima actualización")
                        .modernText(size: .subhead, color: .textTertiary)
                        .fontWeight(.medium)
                }
                .multilineTextAlignment(.center)
                .modernPadding(.horizontal, .xxlarge)
                
                Spacer()
                
                // Optional: Add a subtle call-to-action for future use
                if isIPad {
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "bell")
                                .font(.system(size: 14, weight: .medium))
                            Text("Notificarme cuando esté lista")
                                .font(.system(size: 15, weight: .medium))
                        }
                    }
                    .modernButton(style: .secondary)
                    .modernPadding(.bottom, .xlarge)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modernPadding(.horizontal, .large)
            .background(
                // Subtle background pattern for iPad
                isIPad ? AnyView(
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.02))
                        .frame(width: 400, height: 400)
                        .offset(x: geometry.size.width * 0.7, y: -geometry.size.height * 0.3)
                        .blur(radius: 40)
                ) : AnyView(EmptyView())
            )
        }
    }
}