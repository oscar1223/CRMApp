import SwiftUI
import SwiftData

// MARK: - Studio Settings View (For Studio/Hybrid accounts)
struct StudioSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsArray: [StudioSettings]

    @State private var studioName = ""
    @State private var address = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var website = ""
    @State private var requireDeposit = true
    @State private var depositPercentage: Double = 20
    @State private var allowOnlineBooking = true
    @State private var autoConfirm = false

    private var currentSettings: StudioSettings? {
        settingsArray.first
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Nombre del estudio", text: $studioName)
                    TextField("Dirección", text: $address)
                    TextField("Teléfono", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Sitio web", text: $website)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                } header: {
                    Text("Información del Estudio")
                }

                Section {
                    Toggle("Requerir depósito", isOn: $requireDeposit)
                        .tint(.brandPrimary)

                    if requireDeposit {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Porcentaje de depósito")
                                Spacer()
                                Text("\(Int(depositPercentage))%")
                                    .foregroundColor(.brandPrimary)
                                    .fontWeight(.semibold)
                            }

                            Slider(value: $depositPercentage, in: 10...50, step: 5)
                                .tint(.brandPrimary)
                        }
                    }
                } header: {
                    Text("Política de Depósitos")
                } footer: {
                    Text("Los clientes deberán pagar este porcentaje al reservar")
                }

                Section {
                    Toggle("Permitir reservas online", isOn: $allowOnlineBooking)
                        .tint(.brandPrimary)

                    Toggle("Auto-confirmar reservas", isOn: $autoConfirm)
                        .tint(.brandPrimary)
                } header: {
                    Text("Reservas")
                } footer: {
                    Text("Las reservas se confirmarán automáticamente sin revisión manual")
                }

                Section {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        Label("Notificaciones", systemImage: "bell.fill")
                    }

                    NavigationLink(destination: BusinessHoursView()) {
                        Label("Horario del negocio", systemImage: "clock.fill")
                    }

                    NavigationLink(destination: TaxSettingsView()) {
                        Label("Impuestos y facturación", systemImage: "percent")
                    }
                } header: {
                    Text("Configuración Avanzada")
                }
            }
            .navigationTitle("Configuración del Estudio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveSettings()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadSettings()
            }
        }
    }

    private func loadSettings() {
        guard let settings = currentSettings else { return }

        studioName = settings.studioName
        address = settings.address
        phone = settings.phone
        email = settings.email
        website = settings.website
        requireDeposit = settings.requireDeposit
        depositPercentage = settings.defaultDepositPercentage
        allowOnlineBooking = settings.allowOnlineBooking
        autoConfirm = settings.autoConfirmBookings
    }

    private func saveSettings() {
        if let settings = currentSettings {
            // Update existing
            settings.studioName = studioName
            settings.address = address
            settings.phone = phone
            settings.email = email
            settings.website = website
            settings.requireDeposit = requireDeposit
            settings.defaultDepositPercentage = depositPercentage
            settings.allowOnlineBooking = allowOnlineBooking
            settings.autoConfirmBookings = autoConfirm
            settings.updatedAt = Date()
        } else {
            // Create new
            let newSettings = StudioSettings(
                studioName: studioName,
                address: address,
                phone: phone,
                email: email,
                website: website,
                requireDeposit: requireDeposit,
                defaultDepositPercentage: depositPercentage,
                allowOnlineBooking: allowOnlineBooking,
                autoConfirmBookings: autoConfirm
            )
            modelContext.insert(newSettings)
        }

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Notifications Settings View
private struct NotificationsSettingsView: View {
    @State private var emailNotifications = true
    @State private var smsNotifications = false
    @State private var notifyNewBooking = true
    @State private var notifyDayBefore = true
    @State private var notifyHourBefore = false

    var body: some View {
        Form {
            Section {
                Toggle("Notificaciones por email", isOn: $emailNotifications)
                    .tint(.brandPrimary)

                Toggle("Notificaciones SMS", isOn: $smsNotifications)
                    .tint(.brandPrimary)
            } header: {
                Text("Canales de Notificación")
            }

            Section {
                Toggle("Nueva reserva", isOn: $notifyNewBooking)
                    .tint(.brandPrimary)

                Toggle("Recordatorio 1 día antes", isOn: $notifyDayBefore)
                    .tint(.brandPrimary)

                Toggle("Recordatorio 1 hora antes", isOn: $notifyHourBefore)
                    .tint(.brandPrimary)
            } header: {
                Text("Recordatorios")
            }
        }
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Business Hours View
private struct BusinessHoursView: View {
    @State private var openTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var closeTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var workingDays: Set<Int> = [1, 2, 3, 4, 5, 6]

    private let weekDays = [
        (0, "Domingo"),
        (1, "Lunes"),
        (2, "Martes"),
        (3, "Miércoles"),
        (4, "Jueves"),
        (5, "Viernes"),
        (6, "Sábado")
    ]

    var body: some View {
        Form {
            Section {
                ForEach(weekDays, id: \.0) { day in
                    Toggle(isOn: Binding(
                        get: { workingDays.contains(day.0) },
                        set: { isOn in
                            if isOn {
                                workingDays.insert(day.0)
                            } else {
                                workingDays.remove(day.0)
                            }
                        }
                    )) {
                        Text(day.1)
                    }
                    .tint(.brandPrimary)
                }
            } header: {
                Text("Días Laborables")
            }

            Section {
                DatePicker("Apertura", selection: $openTime, displayedComponents: .hourAndMinute)
                DatePicker("Cierre", selection: $closeTime, displayedComponents: .hourAndMinute)
            } header: {
                Text("Horario")
            }
        }
        .navigationTitle("Horario del Negocio")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Tax Settings View
private struct TaxSettingsView: View {
    @State private var taxRate: Double = 21
    @State private var includeVAT = true
    @State private var businessID = ""

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("IVA")
                        Spacer()
                        Text("\(Int(taxRate))%")
                            .foregroundColor(.brandPrimary)
                            .fontWeight(.semibold)
                    }

                    Slider(value: $taxRate, in: 0...25, step: 1)
                        .tint(.brandPrimary)
                }

                Toggle("Incluir IVA en precios", isOn: $includeVAT)
                    .tint(.brandPrimary)
            } header: {
                Text("Impuestos")
            }

            Section {
                TextField("NIF/CIF", text: $businessID)
            } header: {
                Text("Datos Fiscales")
            } footer: {
                Text("Estos datos aparecerán en las facturas")
            }
        }
        .navigationTitle("Impuestos y Facturación")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    StudioSettingsView()
        .modelContainer(for: StudioSettings.self, inMemory: true)
}
