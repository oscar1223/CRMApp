import SwiftUI

struct ClientsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddClient = false
    @State private var searchText = ""
    @State private var selectedStatus: ClientStatus? = nil
    
    var filteredClients: [Client] {
        var clients = dataManager.clients
        
        if !searchText.isEmpty {
            clients = clients.filter { client in
                client.name.localizedCaseInsensitiveContains(searchText) ||
                client.company.localizedCaseInsensitiveContains(searchText) ||
                client.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let status = selectedStatus {
            clients = clients.filter { $0.status == status }
        }
        
        return clients.sorted { $0.lastContact > $1.lastContact }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "Todos",
                                isSelected: selectedStatus == nil,
                                action: { selectedStatus = nil }
                            )
                            
                            ForEach(ClientStatus.allCases, id: \.self) { status in
                                FilterChip(
                                    title: status.rawValue,
                                    isSelected: selectedStatus == status,
                                    action: { selectedStatus = selectedStatus == status ? nil : status }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Clients List
                if filteredClients.isEmpty {
                    EmptyStateView(
                        icon: "person.2.slash",
                        title: "No hay clientes",
                        message: searchText.isEmpty ? "Agrega tu primer cliente" : "No se encontraron clientes"
                    )
                } else {
                    List {
                        ForEach(filteredClients) { client in
                            NavigationLink(destination: ClientDetailView(client: client)) {
                                ClientRow(client: client)
                            }
                        }
                        .onDelete(perform: deleteClients)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Clientes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddClient = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView()
            }
        }
    }
    
    private func deleteClients(offsets: IndexSet) {
        for index in offsets {
            let client = filteredClients[index]
            dataManager.deleteClient(client)
        }
    }
}

struct ClientRow: View {
    let client: Client
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(client.name.prefix(1)))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                )
            
            // Client Info
            VStack(alignment: .leading, spacing: 4) {
                Text(client.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(client.company)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(client.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text(client.lastContact, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch client.status {
        case .prospect: return .blue
        case .lead: return .green
        case .qualified: return .orange
        case .proposal: return .purple
        case .negotiation: return .yellow
        case .closedWon: return .green
        case .closedLost: return .red
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Buscar clientes...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ClientsView()
        .environmentObject(DataManager())
}
