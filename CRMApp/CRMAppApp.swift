import SwiftUI
import SwiftData

@main
struct CRMAppApp: App {
    @State private var isOnboardingComplete = false

    var body: some Scene {
        WindowGroup {
            RootView(isOnboardingComplete: $isOnboardingComplete)
        }
        .modelContainer(for: [UserProfile.self, Artist.self])
    }
}

// MARK: - Root View (handles onboarding routing)
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: shouldShowOnboarding)
        .onAppear {
            checkOnboardingStatus()
            print("🏁 RootView appeared - Profiles count: \(profiles.count), isOnboardingComplete: \(isOnboardingComplete)")
        }
        .onChange(of: profiles.count) { newCount in
            print("📊 Profiles count changed to: \(newCount)")
            checkOnboardingStatus()
        }
        .onChange(of: isOnboardingComplete) { newValue in
            print("✨ isOnboardingComplete changed to: \(newValue)")
        }
    }

    private var shouldShowOnboarding: Bool {
        let shouldShow = profiles.isEmpty && !isOnboardingComplete
        print("🔍 shouldShowOnboarding: \(shouldShow) (profiles: \(profiles.count), complete: \(isOnboardingComplete))")
        return shouldShow
    }

    private func checkOnboardingStatus() {
        // If profile exists, mark onboarding as complete
        if !profiles.isEmpty {
            print("✅ Profile detected, marking onboarding complete")
            isOnboardingComplete = true
        }
    }
}
