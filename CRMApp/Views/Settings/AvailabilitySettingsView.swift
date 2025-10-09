import SwiftUI

// MARK: - Availability Settings View
struct AvailabilitySettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var workingDays: Set<Int> = [1, 2, 3, 4, 5, 6] // Monday to Saturday
    @State private var startTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var appointmentDuration: Double = 60
    @State private var bufferTime: Double = 15

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
        NavigationView {
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
                    DatePicker("Hora de inicio", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("Hora de cierre", selection: $endTime, displayedComponents: .hourAndMinute)
                } header: {
                    Text("Horario de Trabajo")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Duración de cita por defecto")
                            Spacer()
                            Text("\(Int(appointmentDuration)) min")
                                .foregroundColor(.brandPrimary)
                                .fontWeight(.semibold)
                        }

                        Slider(value: $appointmentDuration, in: 15...240, step: 15)
                            .tint(.brandPrimary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Tiempo de buffer entre citas")
                            Spacer()
                            Text("\(Int(bufferTime)) min")
                                .foregroundColor(.brandPrimary)
                                .fontWeight(.semibold)
                        }

                        Slider(value: $bufferTime, in: 0...60, step: 5)
                            .tint(.brandPrimary)
                    }
                } header: {
                    Text("Configuración de Citas")
                } footer: {
                    Text("El tiempo de buffer se añade automáticamente entre citas para preparación")
                }
            }
            .navigationTitle("Disponibilidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    AvailabilitySettingsView()
}
