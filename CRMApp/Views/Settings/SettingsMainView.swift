import SwiftUI
import SwiftData

// MARK: - Settings Main View (modeled after reference screenshots)
struct SettingsMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showingAccountTypeSheet = false

    private var currentProfile: UserProfile? {
        profiles.first
    }

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
                // Account Type Section (NEW)
                SettingsCard {
                    Button(action: {
                        print("🎯 Account Type button tapped - Current: \(currentProfile?.accountType.displayName ?? "None")")
                        showingAccountTypeSheet = true
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.brandPrimary.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: currentProfile?.accountType.icon ?? "person.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.brandPrimary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tipo de cuenta")
                                    .modernText(size: .body, color: .textPrimary)
                                    .fontWeight(.semibold)
                                Text(currentProfile?.accountType.displayName ?? "No configurado")
                                    .modernText(size: .caption, color: .textSecondary)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textTertiary)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

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
        .sheet(isPresented: $showingAccountTypeSheet) {
            AccountTypePickerSheet(currentType: currentProfile?.accountType ?? .individual) { newType in
                updateAccountType(to: newType)
            }
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Update Account Type
    private func updateAccountType(to newType: AccountType) {
        guard let profile = currentProfile else {
            print("⚠️ No profile found")
            return
        }

        print("🔄 Updating account type from \(profile.accountType.displayName) to \(newType.displayName)")

        profile.accountType = newType
        profile.updatedAt = Date()

        do {
            try modelContext.save()
            print("✅ Account type saved successfully")

            // Force refresh by notifying
            NotificationCenter.default.post(name: NSNotification.Name("AccountTypeChanged"), object: nil)
        } catch {
            print("❌ Error updating account type: \(error)")
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

// MARK: - Account Type Picker Sheet
private struct AccountTypePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let currentType: AccountType
    let onSelect: (AccountType) -> Void

    @State private var selectedType: AccountType

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    init(currentType: AccountType, onSelect: @escaping (AccountType) -> Void) {
        self.currentType = currentType
        self.onSelect = onSelect
        self._selectedType = State(initialValue: currentType)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Cambiar tipo de cuenta")
                            .modernText(size: .headline, color: .textPrimary)
                            .fontWeight(.bold)

                        Text("Selecciona cómo usas la aplicación")
                            .modernText(size: .subhead, color: .textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)

                    // Account type cards
                    VStack(spacing: 12) {
                        accountTypeCard(.individual)
                        accountTypeCard(.studio)
                        accountTypeCard(.hybrid)
                    }
                    .padding(.horizontal, 16)

                    // Save button
                    if selectedType != currentType {
                        saveButton
                    }

                    Spacer(minLength: 20)
                }
                .padding(.bottom, 20)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
    }

    private func accountTypeCard(_ type: AccountType) -> some View {
        let isSelected = selectedType == type
        let isCurrent = currentType == type

        return Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedType = type
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? Color.brandPrimary : Color.backgroundTertiary)
                        .frame(width: 48, height: 48)

                    Image(systemName: type.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .brandPrimary)
                }

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(type.displayName)
                            .modernText(
                                size: .body,
                                color: isSelected ? .brandPrimary : .textPrimary
                            )
                            .fontWeight(.bold)

                        if isCurrent {
                            Text("Actual")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.brandPrimary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.brandPrimary.opacity(0.15)))
                        }
                    }

                    Text(type.description)
                        .modernText(size: .caption, color: .textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.brandPrimary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                isSelected ? Color.brandPrimary : Color.borderSecondary,
                                lineWidth: isSelected ? 2 : 0.5
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.brandPrimary.opacity(0.15) : Color.black.opacity(0.04),
                radius: isSelected ? 16 : 8,
                x: 0,
                y: isSelected ? 6 : 3
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var saveButton: some View {
        Button(action: {
            print("💾 Save button tapped - Selected type: \(selectedType.displayName)")
            onSelect(selectedType)
            print("✅ onSelect called, dismissing sheet")
            dismiss()
        }) {
            HStack(spacing: 8) {
                Text("Guardar cambios")
                    .font(.system(size: 16, weight: .semibold))

                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.brandPrimary)
            )
            .shadow(color: Color.brandPrimary.opacity(0.3), radius: 16, x: 0, y: 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}


