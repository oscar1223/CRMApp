import SwiftUI

// MARK: - Payment Methods View
struct PaymentMethodsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var acceptCash = true
    @State private var acceptCard = true
    @State private var acceptBankTransfer = false
    @State private var acceptBizum = true

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $acceptCash) {
                        HStack(spacing: 12) {
                            Image(systemName: "banknote")
                                .font(.system(size: 18))
                                .foregroundColor(.successGreen)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Efectivo")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Aceptar pagos en efectivo")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .tint(.brandPrimary)

                    Toggle(isOn: $acceptCard) {
                        HStack(spacing: 12) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 18))
                                .foregroundColor(.brandPrimary)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tarjeta")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Visa, Mastercard, Amex")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .tint(.brandPrimary)

                    Toggle(isOn: $acceptBankTransfer) {
                        HStack(spacing: 12) {
                            Image(systemName: "building.columns")
                                .font(.system(size: 18))
                                .foregroundColor(.calendarEventBlue)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Transferencia")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Transferencia bancaria")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .tint(.brandPrimary)

                    Toggle(isOn: $acceptBizum) {
                        HStack(spacing: 12) {
                            Image(systemName: "app.badge")
                                .font(.system(size: 18))
                                .foregroundColor(.warningOrange)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bizum")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Pago instantáneo")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .tint(.brandPrimary)
                } header: {
                    Text("Métodos de Pago Aceptados")
                }

                Section {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.brandPrimary)
                            Text("Añadir cuenta bancaria")
                                .foregroundColor(.brandPrimary)
                        }
                    }
                } header: {
                    Text("Configuración Avanzada")
                } footer: {
                    Text("Añade una cuenta bancaria para recibir pagos directamente")
                }
            }
            .navigationTitle("Métodos de Pago")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
    PaymentMethodsView()
}
