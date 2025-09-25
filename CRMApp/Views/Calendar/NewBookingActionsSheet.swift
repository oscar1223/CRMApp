import SwiftUI

// MARK: - New Booking Actions Sheet
struct NewBookingActionsSheet: View {
    let onCopyShortLink: () -> Void
    let onCopyFullLink: () -> Void
    let onCreateNewLink: () -> Void
    let onAddManual: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack(spacing: isIPad ? 20 : 16) {
            Capsule()
                .fill(Color.textTertiary.opacity(0.4))
                .frame(width: 40, height: 5)
                .modernPadding(.top, .small)
            
            Text("Crear nueva reserva")
                .modernText(size: .headline, color: .textPrimary)
                .fontWeight(.bold)
                .modernPadding(.top, .small)
            
            VStack(spacing: isIPad ? 14 : 12) {
                actionCard(
                    title: "Copiar enlace corto",
                    subtitle: "Ideal para redes sociales",
                    systemIcon: "link",
                    action: onCopyShortLink
                )
                
                actionCard(
                    title: "Copiar enlace completo",
                    subtitle: "Incluye parámetros y tracking",
                    systemIcon: "link.badge.plus",
                    action: onCopyFullLink
                )
                
                actionCard(
                    title: "Crear nuevo enlace",
                    subtitle: "Configura preguntas y precio",
                    systemIcon: "wand.and.stars",
                    action: onCreateNewLink
                )
                
                actionCard(
                    title: "Añadir cita manualmente",
                    subtitle: "Selecciona fecha y hora",
                    systemIcon: "calendar.badge.plus",
                    action: onAddManual
                )
            }
            .modernPadding(.horizontal, .small)
            
            Button("Cerrar") { dismiss() }
                .modernButton(style: .secondary)
                .modernPadding(.bottom, .medium)
        }
        .modernPadding(.horizontal, .medium)
        .modernPadding(.vertical, .small)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 24 : 20)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 24 : 20)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
    }
    
    private func actionCard(title: String, subtitle: String, systemIcon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: isIPad ? 14 : 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: isIPad ? 44 : 40, height: isIPad ? 44 : 40)
                    Image(systemName: systemIcon)
                        .font(.system(size: isIPad ? 18 : 16, weight: .semibold))
                        .foregroundColor(.brandPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .modernText(size: .body, color: .textPrimary)
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .modernText(size: .caption, color: .textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: isIPad ? 14 : 12, weight: .semibold))
                    .foregroundColor(.textTertiary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.backgroundTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.borderLight, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


