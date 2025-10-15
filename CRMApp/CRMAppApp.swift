import SwiftUI
import SwiftData

@main
struct CRMAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [UserProfile.self, Artist.self, Appointment.self, StudioSettings.self])
    }
}

// MARK: - Root View (handles onboarding routing)
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]

    @State private var hasProfile = false

    var body: some View {
        Group {
            if hasProfile || !profiles.isEmpty {
                ContentView()
                    .id("content-\(profiles.count)")
            } else {
                OnboardingView()
                    .id("onboarding")
            }
        }
        .onAppear {
            checkProfiles()
        }
        .onChange(of: profiles.count) { oldCount, newCount in
            checkProfiles()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProfileCreated"))) { _ in
            // Force re-check after a brief delay to ensure SwiftData has synced
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                checkProfiles()
            }
        }
    }

    private func checkProfiles() {
        let hasData = !profiles.isEmpty

        if hasData && !hasProfile {
            withAnimation(.easeInOut(duration: 0.3)) {
                hasProfile = true
            }
        }
    }
}
