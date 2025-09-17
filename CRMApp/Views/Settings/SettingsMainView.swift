import SwiftUI

// MARK: - Settings Main View (modeled after reference screenshots)
struct SettingsMainView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                profileHeader
                paymentsCTA
                settingsSections
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    // MARK: Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.backgroundCard)
                .frame(width: 96, height: 96)
                .overlay(
                    Image("AppIcon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                .padding(.top, 8)
            
            Text("Racsoscar")
                .modernText(size: .headline, color: .textPrimary)
                .fontWeight(.bold)
            
            Text("oscararauzp@gmail.com")
                .modernText(size: .subhead, color: .textSecondary)
            
            Button(action: {}) {
                Text("Editar perfil de artista")
            }
            .modernButton(style: .secondary)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: Payments CTA Card
    private var paymentsCTA: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comienza con pagos")
                .modernText(size: .headline, color: .textInverse)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "creditcard", text: "Solicita y acepta pagos sin efectivo", color: .white)
                FeatureRow(icon: "banknote", text: "Registra pagos en efectivo", color: .white)
                FeatureRow(icon: "calendar.badge.exclamationmark", text: "Protege con depósitos ante cancelaciones", color: .white)
                FeatureRow(icon: "arrow.down.circle", text: "Recibe pagos a tu cuenta bancaria", color: .white)
            }
            
            HStack(spacing: 12) {
                Button(action: {}) { Text("Precios") }.modernButton(style: .secondary)
                Button(action: {}) { Text("Empezar ahora") }.modernButton(style: .primary)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.brandPrimary.opacity(0.25), radius: 18, x: 0, y: 8)
    }
    
    // MARK: Sections List
    private var settingsSections: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ajustes")
                .modernText(size: .subhead, color: .textSecondary)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                SettingsCard {
                    SettingRow(icon: "creditcard", iconColor: .brandPrimary, title: "Métodos de pago", subtitle: "Gestiona los métodos de pago aceptados")
                    Divider().padding(.leading, 52)
                    SettingRow(icon: "building.2", iconColor: .textSecondary, title: "Lugares de trabajo", subtitle: "Gestiona conexiones con estudios")
                    Divider().padding(.leading, 52)
                    SettingRow(icon: "mappin.and.ellipse", iconColor: .textSecondary, title: "Ubicaciones", subtitle: "Gestiona tus ubicaciones")
                    Divider().padding(.leading, 52)
                    SettingRow(icon: "clock.badge.checkmark", iconColor: .textSecondary, title: "Disponibilidad", subtitle: "Gestiona horarios por ubicación")
                }
                
                SettingsCard {
                    SettingRow(icon: "envelope.badge", iconColor: .textSecondary, title: "Solicitudes de reserva", subtitle: "Recibe solicitudes desde tu página")
                    Divider().padding(.leading, 52)
                    SettingRow(icon: "shield", iconColor: .textSecondary, title: "Depósitos de pago", subtitle: "Edita la tarifa por defecto")
                    Divider().padding(.leading, 52)
                    SettingRow(icon: "doc.text", iconColor: .textSecondary, title: "Formularios", subtitle: "Activa o desactiva tus formularios")
                }
                
                SettingsCard {
                    SettingRow(icon: "creditcard.and.123", iconColor: .textSecondary, title: "Gestionar suscripción", subtitle: "Actualiza o cancela tu plan")
                }
            }
        }
    }
}

// MARK: - Building Blocks
private struct SettingsCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(spacing: 0) { content }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.borderSecondary, lineWidth: 0.5)
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

private struct SettingRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
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
                    .modernText(size: .body, color: .textPrimary)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .modernText(size: .caption, color: .textSecondary)
            }
            
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textTertiary)
        }
        .padding(.vertical, 6)
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }
}


