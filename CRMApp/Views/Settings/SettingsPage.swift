import SwiftUI

// MARK: - Settings Page
struct SettingsPage: View {
    @StateObject private var store = SettingsStore()
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Photo
                    Button(action: { showingImagePicker = true }) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 100, height: 100)
                            
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Edit overlay
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            .frame(width: 100, height: 100)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text("\(store.settings.profile.firstName) \(store.settings.profile.lastName)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(store.settings.profile.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Edit Profile Button
                    Button("Editar Perfil") {
                        // Handle edit profile
                    }
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                }
                .padding(.top, 20)
                
                // Settings Sections
                VStack(spacing: 16) {
                    SettingsSection(title: "Configuración", items: [
                        SettingsItem(title: "Payment Methods", icon: "creditcard.fill", color: .green),
                        SettingsItem(title: "Workplaces", icon: "building.2.fill", color: .blue),
                        SettingsItem(title: "Location", icon: "location.fill", color: .red),
                        SettingsItem(title: "Availability", icon: "clock.fill", color: .orange),
                        SettingsItem(title: "Booking Requests", icon: "calendar.badge.plus", color: .purple),
                        SettingsItem(title: "Payment Deposits", icon: "banknote.fill", color: .green),
                        SettingsItem(title: "Forms", icon: "doc.text.fill", color: .blue),
                        SettingsItem(title: "Manage Subscription", icon: "crown.fill", color: .yellow)
                    ])
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
}

// MARK: - Settings Components
struct SettingsSection: View {
    let title: String
    let items: [SettingsItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    SettingsRow(item: item, isLast: index == items.count - 1)
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct SettingsItem {
    let title: String
    let icon: String
    let color: Color
}

struct SettingsRow: View {
    let item: SettingsItem
    let isLast: Bool
    
    var body: some View {
        Button(action: {
            // Handle settings item tap
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.color.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(item.color)
                }
                
                // Title
                Text(item.title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
        }
        .buttonStyle(.plain)
        .overlay(
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5),
            alignment: isLast ? .top : .bottom
        )
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
