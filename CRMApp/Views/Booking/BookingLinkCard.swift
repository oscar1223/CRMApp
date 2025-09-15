import SwiftUI

// MARK: - Simple Booking Link Card
struct BookingLinkCard: View {
    let link: BookingLink
    let onEdit: () -> Void
    let onCopy: () -> Void
    
    private let cardColors: [Color] = [
        .orange, .blue, .purple, .green
    ]
    
    private var cardColor: Color {
        let hash = abs(link.title.hashValue)
        return cardColors[hash % cardColors.count]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with accent color
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(link.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Enlace de reserva")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "link")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.all, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardColor)
            )
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // URL preview
                HStack(spacing: 8) {
                    Image(systemName: "globe")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(simplifiedURL)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: onCopy) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12, weight: .medium))
                            Text("Copiar")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    
                    Button(action: onEdit) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .medium))
                            Text("Editar")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
            .padding(.all, 16)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: cardColor.opacity(0.2), radius: 8, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
    
    private var simplifiedURL: String {
        if let url = URL(string: link.url) {
            return url.host ?? link.url
        }
        return link.url
    }
}

// MARK: - Simple Edit Booking Link Modal
struct EditBookingLinkModal: View {
    @Binding var link: BookingLink?
    @Binding var title: String
    @Binding var url: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button("Cancelar") {
                            onCancel()
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Editar Enlace")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Guardar") {
                            onSave()
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || url.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding(.all, 24)
                .background(Color(.secondarySystemGroupedBackground))
                .overlay(
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
                
                // Form content
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Detalles del Enlace")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Título")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Ej: Reserva General", text: $title)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color(.separator), lineWidth: 1)
                                                )
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("URL")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("https://ejemplo.com/reserva", text: $url)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color(.separator), lineWidth: 1)
                                                )
                                        )
                                        .keyboardType(.URL)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                        )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                
                                Text("Información")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            
                            Text("El enlace será copiado al portapapeles cuando los usuarios hagan clic en 'Copiar'. Asegúrate de que la URL sea correcta y esté accesible.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.all, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.all, 24)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
}

// MARK: - Simple Client Row
struct ClientRow: View {
    let client: Client
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    private var avatarColor: Color {
        let colors: [Color] = [.orange, .blue, .purple, .green]
        let hash = abs(client.name.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Simple avatar
            ZStack {
                Circle()
                    .fill(avatarColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Circle()
                    .stroke(avatarColor.opacity(0.3), lineWidth: 2)
                    .frame(width: 48, height: 48)
                
                Text(String(client.name.prefix(1)).uppercased())
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(avatarColor)
            }
            
            // Client info
            VStack(alignment: .leading, spacing: 6) {
                Text(client.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "envelope")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(client.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if !client.phone.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "phone")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(client.phone)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                }
            }
        }
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Simple Client Modal
struct ClientModal: View {
    @Binding var client: Client?
    @Binding var name: String
    @Binding var email: String
    @Binding var phone: String
    @Binding var notes: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button("Cancelar") {
                            onCancel()
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(client == nil ? "Nuevo Cliente" : "Editar Cliente")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Guardar") {
                            onSave()
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || email.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding(.all, 24)
                .background(Color(.secondarySystemGroupedBackground))
                .overlay(
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
                
                // Form content
                ScrollView {
                    VStack(spacing: 24) {
                        // Client preview
                        if !name.isEmpty {
                            VStack(spacing: 16) {
                                let previewColor: Color = .blue
                                
                                ZStack {
                                    Circle()
                                        .fill(previewColor.opacity(0.15))
                                        .frame(width: 80, height: 80)
                                    
                                    Circle()
                                        .stroke(previewColor.opacity(0.3), lineWidth: 3)
                                        .frame(width: 80, height: 80)
                                    
                                    Text(String(name.prefix(1)).uppercased())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(previewColor)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(name.isEmpty ? "Nombre del Cliente" : name)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    if !email.isEmpty {
                                        Text(email)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.all, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        
                        // Information form
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Información del Cliente")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "person")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Text("Nombre completo")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    TextField("Ej: María García", text: $name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color(.separator), lineWidth: 1)
                                                )
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "envelope")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Text("Email")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    TextField("maria@ejemplo.com", text: $email)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color(.separator), lineWidth: 1)
                                                )
                                        )
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "phone")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Text("Teléfono")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    TextField("+34 600 123 456", text: $phone)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color(.separator), lineWidth: 1)
                                                )
                                        )
                                        .keyboardType(.phonePad)
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                        )
                        
                        // Notes section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text("Notas")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            TextField("Notas adicionales sobre el cliente...", text: $notes, axis: .vertical)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.separator), lineWidth: 1)
                                        )
                                )
                                .lineLimit(4...8)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                        )
                    }
                    .padding(.all, 24)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
}