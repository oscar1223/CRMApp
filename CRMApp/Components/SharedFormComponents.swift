import SwiftUI

// MARK: - Shared Form Components

// MARK: - Form Field
struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textSecondary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.backgroundCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.borderSecondary, lineWidth: 0.5)
                        )
                )
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Form Section
struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 16)

            content()
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    var onClear: (() -> Void)?

    private var isIPad: Bool {
        UIDevice.isIPad
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: isIPad ? 16 : 14))
                .foregroundColor(.textTertiary)

            TextField(placeholder, text: $text)
                .modernText(size: isIPad ? .body : .subhead, color: .textPrimary)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onClear?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: isIPad ? 16 : 14))
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(isIPad ? 14 : 12)
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 14 : 12, style: .continuous)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 14 : 12, style: .continuous)
                        .stroke(Color.borderSecondary, lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    private var isIPad: Bool {
        UIDevice.isIPad
    }

    var body: some View {
        VStack(spacing: isIPad ? 24 : 20) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: isIPad ? 72 : 64, weight: .light))
                .foregroundColor(.textTertiary.opacity(0.5))

            VStack(spacing: isIPad ? 12 : 8) {
                Text(title)
                    .modernText(size: isIPad ? .headline : .body, color: .textPrimary)
                    .fontWeight(.bold)

                Text(message)
                    .modernText(size: isIPad ? .subhead : .caption, color: .textSecondary)
                    .multilineTextAlignment(.center)
                    .modernPadding(.horizontal, .large)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text(actionTitle)
                    }
                }
                .modernButton(style: .primary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SearchBar(text: .constant("Test"), placeholder: "Buscar...")
            .padding()

        FormField(title: "Nombre", text: .constant(""), placeholder: "Introduce el nombre")

        EmptyStateView(
            icon: "person.3.fill",
            title: "No hay datos",
            message: "Añade elementos para comenzar",
            actionTitle: "Añadir ahora",
            action: {}
        )
    }
}
