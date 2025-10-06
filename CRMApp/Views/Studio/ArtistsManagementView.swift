import SwiftUI

// MARK: - Artists Management View (Placeholder for Phase 2)
struct ArtistsManagementView: View {
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ScrollView {
            VStack(spacing: isIPad ? 32 : 24) {
                headerSection
                comingSoonCard
                mockArtistsList
                Spacer(minLength: isIPad ? 60 : 40)
            }
            .modernPadding(.horizontal, .medium)
            .modernPadding(.top, .large)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.backgroundPrimary,
                    Color.backgroundTertiary,
                    Color.brandPrimary.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: isIPad ? 16 : 12) {
            Image(systemName: "person.3.fill")
                .font(.system(size: isIPad ? 64 : 56, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.brandPrimary.opacity(0.2), radius: 20, x: 0, y: 10)

            VStack(spacing: isIPad ? 8 : 6) {
                Text("Gestión de Artistas")
                    .modernText(size: isIPad ? .title : .headline, color: .textPrimary)
                    .fontWeight(.bold)

                Text("Administra tu equipo de tatuadores")
                    .modernText(size: isIPad ? .body : .subhead, color: .textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Coming Soon Card
    private var comingSoonCard: some View {
        VStack(spacing: isIPad ? 20 : 16) {
            // Badge
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .semibold))
                Text("Próximamente")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: Color.brandPrimary.opacity(0.3), radius: 12, x: 0, y: 6)

            // Message
            VStack(spacing: isIPad ? 12 : 8) {
                Text("Gestiona tu equipo fácilmente")
                    .modernText(size: isIPad ? .headline : .body, color: .textPrimary)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Pronto podrás añadir artistas, gestionar sus horarios, asignar citas, y ver estadísticas individuales de rendimiento.")
                    .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .modernPadding(.horizontal, .medium)
        }
        .modernPadding(.vertical, .large)
        .modernPadding(.horizontal, .medium)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 24 : 20, style: .continuous)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 24 : 20, style: .continuous)
                        .stroke(Color.borderLight, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 8)
    }

    // MARK: - Mock Artists List
    private var mockArtistsList: some View {
        VStack(alignment: .leading, spacing: isIPad ? 20 : 16) {
            Text("Vista previa")
                .modernText(size: isIPad ? .body : .subhead, color: .textPrimary)
                .fontWeight(.bold)
                .modernPadding(.horizontal, .small)

            VStack(spacing: isIPad ? 16 : 12) {
                mockArtistRow(
                    name: "María González",
                    specialty: "Realismo",
                    status: "Activo",
                    color: .successGreen
                )

                mockArtistRow(
                    name: "Carlos Ruiz",
                    specialty: "Japonés",
                    status: "Activo",
                    color: .successGreen
                )

                mockArtistRow(
                    name: "Ana Martínez",
                    specialty: "Minimalista",
                    status: "Inactivo",
                    color: .textTertiary
                )
            }
        }
    }

    // MARK: - Mock Artist Row
    private func mockArtistRow(name: String, specialty: String, status: String, color: Color) -> some View {
        HStack(spacing: isIPad ? 16 : 12) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.brandPrimary.opacity(0.6), Color.brandPrimary.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: isIPad ? 56 : 48, height: isIPad ? 56 : 48)
                .overlay(
                    Text(name.prefix(1))
                        .modernText(size: isIPad ? .headline : .body, color: .white)
                        .fontWeight(.bold)
                )

            // Info
            VStack(alignment: .leading, spacing: isIPad ? 4 : 2) {
                Text(name)
                    .modernText(size: isIPad ? .body : .subhead, color: .textPrimary)
                    .fontWeight(.semibold)

                Text(specialty)
                    .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
            }

            Spacer()

            // Status badge
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: isIPad ? 8 : 6, height: isIPad ? 8 : 6)

                Text(status)
                    .font(.system(size: isIPad ? 12 : 10, weight: .medium))
                    .foregroundColor(color)
            }
            .padding(.horizontal, isIPad ? 10 : 8)
            .padding(.vertical, isIPad ? 6 : 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.1))
            )

            Image(systemName: "lock.fill")
                .font(.system(size: isIPad ? 16 : 14, weight: .medium))
                .foregroundColor(.textTertiary)
        }
        .modernPadding(.all, .medium)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 16 : 14, style: .continuous)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 16 : 14, style: .continuous)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .opacity(0.6)
    }
}

#Preview {
    ArtistsManagementView()
}
