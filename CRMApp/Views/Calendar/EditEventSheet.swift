import SwiftUI

// MARK: - Edit Event Sheet (styled with app design system)
struct EditEventSheet: View {
    @State var title: String
    @State var startDate: Date
    @State var endDate: Date
    @State var isAllDay: Bool
    let onSave: (_ title: String, _ start: Date, _ end: Date, _ isAllDay: Bool) -> Void
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: isIPad ? 16 : 12) {
                // Drag indicator
                Capsule()
                    .fill(Color.textTertiary.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .modernPadding(.top, .small)
                
                // Header
                HStack(spacing: 12) {
                    Text("Editar cita")
                        .modernText(size: .headline, color: .textPrimary)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Cancelar") { dismiss() }
                        .modernButton(style: .secondary)
                }
                
                // Details card
                VStack(alignment: .leading, spacing: isIPad ? 12 : 10) {
                    Text("Detalles")
                        .modernText(size: .subhead, color: .textSecondary)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Título")
                            .modernText(size: .caption, color: .textSecondary)
                        TextField("Título de la cita", text: $title)
                            .modernInput()
                    }
                }
                .modernCard()
                
                // Schedule card
                VStack(alignment: .leading, spacing: isIPad ? 12 : 10) {
                    Text("Horario")
                        .modernText(size: .subhead, color: .textSecondary)
                        .fontWeight(.semibold)
                    
                    // All day toggle
                    HStack {
                        Toggle("Todo el día", isOn: $isAllDay)
                            .labelsHidden()
                        Text("Todo el día")
                            .modernText(size: .body, color: .textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.backgroundTertiary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.borderPrimary, lineWidth: 1)
                            )
                    )
                    
                    // Start date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Inicio")
                            .modernText(size: .caption, color: .textSecondary)
                        DatePicker(
                            "",
                            selection: $startDate,
                            displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .modernInput()
                    }
                    
                    // End date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Fin")
                            .modernText(size: .caption, color: .textSecondary)
                        DatePicker(
                            "",
                            selection: $endDate,
                            displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .modernInput()
                    }
                }
                .modernCard()
                
                // Actions
                HStack(spacing: isIPad ? 12 : 8) {
                    Button {
                        onDelete()
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                            Text("Eliminar cita")
                        }
                    }
                    .modernButton(style: .danger)
                    
                    Spacer()
                    
                    Button("Guardar") {
                        onSave(title, startDate, endDate, isAllDay)
                        dismiss()
                    }
                    .modernButton(style: .primary)
                }
                .modernPadding(.top, .small)
            }
            .modernPadding(.horizontal, .medium)
            .modernPadding(.bottom, .large)
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
    }
}


