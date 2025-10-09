import SwiftUI

// MARK: - Shared Card Components

// MARK: - Stat Card (Unified)
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = .brandPrimary
    var style: StatCardStyle = .default

    private var isIPad: Bool {
        UIDevice.isIPad
    }

    var body: some View {
        VStack(spacing: style.spacing) {
            Image(systemName: icon)
                .font(.system(size: style.iconSize(isIPad: isIPad), weight: .semibold))
                .foregroundColor(color)

            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: style.valueSize(isIPad: isIPad), weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(title)
                    .font(.system(size: style.titleSize(isIPad: isIPad), weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, style.verticalPadding(isIPad: isIPad))
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 14 : 12, style: .continuous)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 14 : 12, style: .continuous)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

enum StatCardStyle {
    case `default`
    case mini
    case large

    func iconSize(isIPad: Bool) -> CGFloat {
        switch self {
        case .mini: return isIPad ? 24 : 20
        case .default: return isIPad ? 28 : 24
        case .large: return isIPad ? 32 : 28
        }
    }

    func valueSize(isIPad: Bool) -> CGFloat {
        switch self {
        case .mini: return isIPad ? 18 : 16
        case .default: return isIPad ? 20 : 18
        case .large: return isIPad ? 24 : 20
        }
    }

    func titleSize(isIPad: Bool) -> CGFloat {
        switch self {
        case .mini: return isIPad ? 11 : 10
        case .default: return isIPad ? 12 : 11
        case .large: return isIPad ? 14 : 12
        }
    }

    func verticalPadding(isIPad: Bool) -> CGFloat {
        switch self {
        case .mini: return isIPad ? 12 : 10
        case .default: return isIPad ? 16 : 14
        case .large: return isIPad ? 20 : 16
        }
    }

    var spacing: CGFloat {
        switch self {
        case .mini: return 8
        case .default: return 10
        case .large: return 12
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var iconColor: Color = .brandPrimary

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.backgroundTertiary)
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)

                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }

            Spacer()
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .brandPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.1))
                )
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let text: String
    let color: Color
    var showIcon: Bool = true
    var icon: String?

    private var isIPad: Bool {
        UIDevice.isIPad
    }

    var body: some View {
        HStack(spacing: 4) {
            if showIcon {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: isIPad ? 10 : 9))
                } else {
                    Circle()
                        .fill(color)
                        .frame(width: isIPad ? 8 : 6, height: isIPad ? 8 : 6)
                }
            }

            Text(text)
                .font(.system(size: isIPad ? 12 : 10, weight: .medium))
                .foregroundColor(color)
        }
        .padding(.horizontal, isIPad ? 10 : 8)
        .padding(.vertical, isIPad ? 6 : 4)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Avatar Circle
struct AvatarCircle: View {
    let initials: String
    var size: CGFloat = 56
    var gradient: [Color] = [
        Color.brandPrimary.opacity(0.6),
        Color.brandPrimary.opacity(0.3)
    ]

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    private var isIPad: Bool {
        UIDevice.isIPad
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                HStack {
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.borderSecondary, lineWidth: 0.5)
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                StatCard(
                    icon: "eurosign.circle.fill",
                    title: "Revenue",
                    value: "2,450€",
                    color: .successGreen
                )

                StatCard(
                    icon: "calendar",
                    title: "Bookings",
                    value: "24",
                    style: .mini
                )
            }

            InfoRow(icon: "envelope.fill", title: "Email", value: "test@example.com")

            HStack {
                FilterChip(title: "All", isSelected: true, action: {})
                FilterChip(title: "Active", isSelected: false, action: {})
            }

            StatusBadge(text: "Active", color: .successGreen, icon: "checkmark.circle.fill")

            AvatarCircle(initials: "AB")

            QuickActionCard(
                icon: "person.3.fill",
                title: "Artists",
                subtitle: "Manage team",
                color: .brandPrimary,
                action: {}
            )
        }
        .padding()
    }
}
