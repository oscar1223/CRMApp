import SwiftUI
import SwiftData

// MARK: - Artists Management View (Refactored)
struct ArtistsManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var artists: [Artist]

    @State private var showingAddArtist = false
    @State private var showingArtistDetail: Artist?
    @State private var searchText = ""

    private var filteredArtists: [Artist] {
        if searchText.isEmpty {
            return artists.sorted { $0.name < $1.name }
        }
        return artists.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.specialty.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.name < $1.name }
    }

    var body: some View {
        ZStack {
            Color.clear.studioBackground()

            VStack(spacing: 0) {
                headerSection

                SearchBar(text: $searchText, placeholder: "Buscar artistas...")
                    .modernPadding(.horizontal, .medium)
                    .modernPadding(.top, .medium)

                if filteredArtists.isEmpty {
                    EmptyStateView(
                        icon: searchText.isEmpty ? "person.3.fill" : "magnifyingglass",
                        title: searchText.isEmpty ? "No hay artistas" : "Sin resultados",
                        message: searchText.isEmpty ?
                            "Añade artistas a tu equipo para comenzar" :
                            "No se encontraron artistas con '\(searchText)'",
                        actionTitle: searchText.isEmpty ? "Añadir primer artista" : nil,
                        action: searchText.isEmpty ? { showingAddArtist = true } : nil
                    )
                } else {
                    artistsList
                }
            }
        }
        .sheet(isPresented: $showingAddArtist) {
            AddArtistSheet(modelContext: modelContext)
        }
        .sheet(item: $showingArtistDetail) { artist in
            ArtistDetailSheet(artist: artist, modelContext: modelContext)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Artistas")
                    .modernText(size: UIDevice.isIPad ? .title : .headline, color: .textPrimary)
                    .fontWeight(.bold)

                Text("\(filteredArtists.count) miembros del equipo")
                    .modernText(size: UIDevice.isIPad ? .subhead : .caption, color: .textSecondary)
            }

            Spacer()

            Button(action: { showingAddArtist = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: UIDevice.isIPad ? 14 : 12, weight: .semibold))
                    Text("Añadir")
                        .font(.system(size: UIDevice.isIPad ? 14 : 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, UIDevice.isIPad ? 16 : 12)
                .padding(.vertical, UIDevice.isIPad ? 10 : 8)
                .background(
                    RoundedRectangle(cornerRadius: UIDevice.isIPad ? 12 : 10, style: .continuous)
                        .fill(Color.brandPrimary)
                )
                .shadow(color: Color.brandPrimary.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
        .modernPadding(.horizontal, .medium)
        .modernPadding(.top, .large)
    }

    // MARK: - Artists List
    private var artistsList: some View {
        ScrollView {
            LazyVStack(spacing: UIDevice.isIPad ? 16 : 12) {
                ForEach(filteredArtists) { artist in
                    ArtistRow(artist: artist)
                        .onTapGesture {
                            showingArtistDetail = artist
                        }
                }
            }
            .modernPadding(.horizontal, .medium)
            .modernPadding(.top, .medium)
            .contentCard()
        }
    }
}

// MARK: - Artist Row Component (Refactored)
private struct ArtistRow: View {
    let artist: Artist

    var body: some View {
        HStack(spacing: UIDevice.isIPad ? 16 : 12) {
            AvatarCircle(
                initials: artist.initials,
                size: UIDevice.isIPad ? 64 : 56
            )

            VStack(alignment: .leading, spacing: UIDevice.isIPad ? 6 : 4) {
                Text(artist.name)
                    .modernText(size: UIDevice.isIPad ? .body : .subhead, color: .textPrimary)
                    .fontWeight(.semibold)

                Text(artist.specialty)
                    .modernText(size: UIDevice.isIPad ? .subhead : .caption, color: .textSecondary)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text("\(artist.totalAppointments) citas")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.textTertiary)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text(String(format: "%.1f", artist.rating))
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.warningOrange)
                }
            }

            Spacer()

            VStack(spacing: 8) {
                StatusBadge(
                    text: artist.status.displayName,
                    color: artist.status.colorValue
                )

                Image(systemName: "chevron.right")
                    .font(.system(size: UIDevice.isIPad ? 14 : 12, weight: .semibold))
                    .foregroundColor(.textTertiary)
            }
        }
        .modernPadding(.all, .medium)
        .modernCard()
    }
}

// MARK: - Add Artist Sheet (Refactored)
private struct AddArtistSheet: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var specialty = ""
    @State private var status: ArtistStatus = .active

    private var isValid: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty && !specialty.isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    FormField(title: "Nombre", text: $name, placeholder: "Nombre del artista")
                    FormField(title: "Email", text: $email, placeholder: "email@ejemplo.com", keyboardType: .emailAddress, autocapitalization: .never)
                    FormField(title: "Teléfono", text: $phone, placeholder: "+34 600 000 000", keyboardType: .phonePad)
                    FormField(title: "Especialidad", text: $specialty, placeholder: "Realismo, Japonés, etc.")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estado")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textSecondary)

                        Picker("Estado", selection: $status) {
                            ForEach([ArtistStatus.active, .inactive, .vacation], id: \.self) { status in
                                Text(status.displayName).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Añadir Artista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") { saveArtist() }
                        .foregroundColor(isValid ? .brandPrimary : .textTertiary)
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveArtist() {
        let newArtist = Artist(
            name: name,
            email: email,
            phone: phone,
            specialty: specialty,
            status: status
        )
        modelContext.insert(newArtist)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Artist Detail Sheet (Refactored)
private struct ArtistDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let artist: Artist
    let modelContext: ModelContext

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    artistHeader
                    statsSection
                    infoSection
                    actionsSection

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditArtistSheet(artist: artist, modelContext: modelContext)
        }
        .alert("Eliminar Artista", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) { deleteArtist() }
        } message: {
            Text("¿Estás seguro de eliminar a \(artist.name)? Esta acción no se puede deshacer.")
        }
    }

    private var artistHeader: some View {
        VStack(spacing: 16) {
            AvatarCircle(initials: artist.initials, size: 96)
                .shadow(color: Color.brandPrimary.opacity(0.3), radius: 20, x: 0, y: 10)

            VStack(spacing: 8) {
                Text(artist.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(artist.specialty)
                    .modernText(size: .body, color: .textSecondary)

                StatusBadge(
                    text: artist.status.displayName,
                    color: artist.status.colorValue
                )
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "calendar",
                title: "Citas",
                value: "\(artist.totalAppointments)"
            )

            StatCard(
                icon: "eurosign.circle",
                title: "Este mes",
                value: String(format: "%.0f€", artist.monthlyRevenue)
            )

            StatCard(
                icon: "star.fill",
                title: "Rating",
                value: String(format: "%.1f", artist.rating)
            )
        }
        .padding(.horizontal, 16)
    }

    private var infoSection: some View {
        VStack(spacing: 12) {
            InfoRow(icon: "envelope.fill", title: "Email", value: artist.email)
            Divider().padding(.leading, 52)
            InfoRow(icon: "phone.fill", title: "Teléfono", value: artist.phone)
            Divider().padding(.leading, 52)
            InfoRow(
                icon: "calendar",
                title: "Desde",
                value: artist.joinedDate.formatted(date: .abbreviated, time: .omitted)
            )
        }
        .padding(16)
        .modernCard()
        .padding(.horizontal, 16)
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: { showingEditSheet = true }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Editar información")
                }
            }
            .modernButton(style: .primary)
            .padding(.horizontal, 16)

            Button(action: { showingDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Eliminar artista")
                }
                .foregroundColor(.errorRed)
            }
            .modernButton(style: .secondary)
            .padding(.horizontal, 16)
        }
    }

    private func deleteArtist() {
        modelContext.delete(artist)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Edit Artist Sheet (Refactored)
private struct EditArtistSheet: View {
    @Environment(\.dismiss) private var dismiss
    let artist: Artist
    let modelContext: ModelContext

    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var specialty: String
    @State private var status: ArtistStatus

    init(artist: Artist, modelContext: ModelContext) {
        self.artist = artist
        self.modelContext = modelContext
        _name = State(initialValue: artist.name)
        _email = State(initialValue: artist.email)
        _phone = State(initialValue: artist.phone)
        _specialty = State(initialValue: artist.specialty)
        _status = State(initialValue: artist.status)
    }

    private var isValid: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty && !specialty.isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    FormField(title: "Nombre", text: $name, placeholder: "Nombre del artista")
                    FormField(title: "Email", text: $email, placeholder: "email@ejemplo.com", keyboardType: .emailAddress, autocapitalization: .never)
                    FormField(title: "Teléfono", text: $phone, placeholder: "+34 600 000 000", keyboardType: .phonePad)
                    FormField(title: "Especialidad", text: $specialty, placeholder: "Realismo, Japonés, etc.")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estado")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textSecondary)

                        Picker("Estado", selection: $status) {
                            ForEach([ArtistStatus.active, .inactive, .vacation], id: \.self) { status in
                                Text(status.displayName).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Editar Artista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") { saveChanges() }
                        .foregroundColor(isValid ? .brandPrimary : .textTertiary)
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveChanges() {
        artist.name = name
        artist.email = email
        artist.phone = phone
        artist.specialty = specialty
        artist.status = status
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    ArtistsManagementView()
        .modelContainer(for: Artist.self, inMemory: true)
}
