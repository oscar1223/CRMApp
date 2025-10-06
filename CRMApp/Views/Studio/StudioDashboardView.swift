import SwiftUI

// MARK: - Studio Dashboard View (Placeholder for Phase 2)
struct StudioDashboardView: View {
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ScrollView {
            VStack(spacing: isIPad ? 32 : 24) {
                headerSection
                comingSoonCard
                featuresPreview
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
            Image(systemName: "building.2.fill")
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
                Text("Gestión de Estudio")
                    .modernText(size: isIPad ? .title : .headline, color: .textPrimary)
                    .fontWeight(.bold)

                Text("Administra tu equipo y operaciones")
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
                Text("Estamos construyendo algo increíble")
                    .modernText(size: isIPad ? .headline : .body, color: .textPrimary)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Las herramientas de gestión de estudio estarán disponibles pronto. Podrás administrar artistas, horarios compartidos, reportes y mucho más.")
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

    // MARK: - Features Preview
    private var featuresPreview: some View {
        VStack(alignment: .leading, spacing: isIPad ? 20 : 16) {
            Text("Funciones planificadas")
                .modernText(size: isIPad ? .body : .subhead, color: .textPrimary)
                .fontWeight(.bold)
                .modernPadding(.horizontal, .small)

            VStack(spacing: isIPad ? 16 : 12) {
                featureRow(
                    icon: "person.3.fill",
                    title: "Gestión de Artistas",
                    description: "Administra tu equipo de tatuadores"
                )

                featureRow(
                    icon: "calendar.badge.clock",
                    title: "Calendario Compartido",
                    description: "Visualiza y coordina horarios del estudio"
                )

                featureRow(
                    icon: "chart.bar.fill",
                    title: "Reportes del Estudio",
                    description: "Analytics y métricas de rendimiento"
                )

                featureRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "Asignación de Citas",
                    description: "Distribuye reservas entre artistas"
                )
            }
        }
    }

    // MARK: - Feature Row
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: isIPad ? 16 : 12) {
            ZStack {
                RoundedRectangle(cornerRadius: isIPad ? 14 : 12, style: .continuous)
                    .fill(Color.backgroundTertiary)
                    .frame(width: isIPad ? 56 : 48, height: isIPad ? 56 : 48)

                Image(systemName: icon)
                    .font(.system(size: isIPad ? 24 : 20, weight: .semibold))
                    .foregroundColor(.brandPrimary.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: isIPad ? 4 : 2) {
                Text(title)
                    .modernText(size: isIPad ? .body : .subhead, color: .textPrimary)
                    .fontWeight(.semibold)

                Text(description)
                    .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
            }

            Spacer()

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
    }
}

#Preview {
    StudioDashboardView()
}
