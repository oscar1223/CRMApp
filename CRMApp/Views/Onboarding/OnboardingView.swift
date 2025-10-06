import SwiftUI
import SwiftData

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isOnboardingComplete: Bool

    @State private var selectedType: AccountType?
    @State private var isAnimating = false

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.backgroundPrimary,
                    Color.backgroundTertiary,
                    Color.brandPrimary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: isIPad ? 40 : 32) {
                    // Header
                    headerSection

                    // Account type cards
                    VStack(spacing: isIPad ? 20 : 16) {
                        accountTypeCard(.individual)
                        accountTypeCard(.studio)
                        accountTypeCard(.hybrid)
                    }
                    .modernPadding(.horizontal, .medium)

                    // Continue button
                    if selectedType != nil {
                        continueButton
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: isIPad ? 60 : 40)
                }
                .padding(.top, isIPad ? 60 : 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: isIPad ? 20 : 16) {
            // App icon placeholder
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isIPad ? 100 : 80, height: isIPad ? 100 : 80)
                    .shadow(color: Color.brandPrimary.opacity(0.3), radius: 20, x: 0, y: 10)

                Image(systemName: "paintbrush.fill")
                    .font(.system(size: isIPad ? 48 : 40, weight: .semibold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1 : 0.5)
            .opacity(isAnimating ? 1 : 0)

            VStack(spacing: isIPad ? 12 : 8) {
                Text("Bienvenido a CRMApp")
                    .modernText(size: isIPad ? .title : .headline, color: .textPrimary)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("¿Cómo vas a usar la aplicación?")
                    .modernText(size: isIPad ? .body : .subhead, color: .textSecondary)
                    .multilineTextAlignment(.center)
                    .modernPadding(.horizontal, .large)
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
        }
    }

    // MARK: - Account Type Card
    private func accountTypeCard(_ type: AccountType) -> some View {
        let isSelected = selectedType == type

        return Button(action: {
            print("🎯 Selected account type: \(type.displayName)")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedType = type
            }
        }) {
            HStack(spacing: isIPad ? 20 : 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: isIPad ? 16 : 14, style: .continuous)
                        .fill(isSelected ? Color.brandPrimary : Color.backgroundTertiary)
                        .frame(width: isIPad ? 64 : 56, height: isIPad ? 64 : 56)

                    Image(systemName: type.icon)
                        .font(.system(size: isIPad ? 28 : 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .brandPrimary)
                }
                .shadow(
                    color: isSelected ? Color.brandPrimary.opacity(0.3) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )

                // Text content
                VStack(alignment: .leading, spacing: isIPad ? 6 : 4) {
                    Text(type.displayName)
                        .modernText(
                            size: isIPad ? .headline : .body,
                            color: isSelected ? .brandPrimary : .textPrimary
                        )
                        .fontWeight(.bold)

                    Text(type.description)
                        .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: isIPad ? 28 : 24, weight: .semibold))
                        .foregroundColor(.brandPrimary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(isIPad ? 24 : 20)
            .background(
                RoundedRectangle(cornerRadius: isIPad ? 20 : 16, style: .continuous)
                    .fill(Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: isIPad ? 20 : 16, style: .continuous)
                            .stroke(
                                isSelected ? Color.brandPrimary : Color.borderSecondary,
                                lineWidth: isSelected ? 2 : 0.5
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.brandPrimary.opacity(0.15) : Color.black.opacity(0.06),
                radius: isSelected ? 20 : 12,
                x: 0,
                y: isSelected ? 8 : 4
            )
            .scaleEffect(isSelected ? 1.02 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Continue Button
    private var continueButton: some View {
        Button(action: {
            print("🚀 Continue button tapped")
            completeOnboarding()
        }) {
            HStack(spacing: isIPad ? 10 : 8) {
                Text("Continuar")
                    .font(.system(size: isIPad ? 18 : 16, weight: .semibold))

                Image(systemName: "arrow.right")
                    .font(.system(size: isIPad ? 16 : 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isIPad ? 18 : 16)
            .background(
                RoundedRectangle(cornerRadius: isIPad ? 16 : 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: Color.brandPrimary.opacity(0.4), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(PlainButtonStyle())
        .modernPadding(.horizontal, .medium)
        .modernPadding(.top, .small)
    }

    // MARK: - Actions
    private func completeOnboarding() {
        guard let type = selectedType else { return }

        print("🎉 Onboarding completed - Selected: \(type.displayName)")

        // Create user profile
        let profile = UserProfile(accountType: type)
        modelContext.insert(profile)

        // Save context
        do {
            try modelContext.save()
            print("✅ User profile saved successfully")

            // Complete onboarding with animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                isOnboardingComplete = true
            }
        } catch {
            print("❌ Error saving user profile: \(error)")
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
