import SwiftUI

struct ActivitiesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddActivity = false
    @State private var searchText = ""
    @State private var selectedType: ActivityType? = nil
    @State private var selectedClient: Client? = nil
    
    var filteredActivities: [Activity] {
        var activities = dataManager.activities
        
        if !searchText.isEmpty {
            activities = activities.filter { activity in
                activity.title.localizedCaseInsensitiveContains(searchText) ||
                activity.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let type = selectedType {
            activities = activities.filter { $0.type == type }
        }
        
        if let client = selectedClient {
            activities = activities.filter { $0.clientId == client.id }
        }
        
        return activities.sorted { $0.date > $1.date }
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
                                title: "Todas",
                                isSelected: selectedType == nil && selectedClient == nil,
                                action: { 
                                    selectedType = nil
                                    selectedClient = nil
                                }
                            )
                            
                            // Type Filters
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    isSelected: selectedType == type,
                                    action: { 
                                        selectedType = selectedType == type ? nil : type
                                        selectedClient = nil
                                    }
                                )
                            }
                            
                            // Client Filters
                            ForEach(dataManager.clients.prefix(3)) { client in
                                FilterChip(
                                    title: client.name,
                                    isSelected: selectedClient?.id == client.id,
                                    action: { 
                                        selectedClient = selectedClient?.id == client.id ? nil : client
                                        selectedType = nil
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Activities List
                if filteredActivities.isEmpty {
                    EmptyStateView(
                        icon: "clock",
                        title: "No hay actividades",
                        message: searchText.isEmpty ? "Agrega tu primera actividad" : "No se encontraron actividades"
                    )
                } else {
                    List {
                        ForEach(filteredActivities) { activity in
                            NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                ActivityRow(activity: activity)
                            }
                        }
                        .onDelete(perform: deleteActivities)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Actividades")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddActivity = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView()
            }
        }
    }
    
    private func deleteActivities(offsets: IndexSet) {
        for index in offsets {
            let activity = filteredActivities[index]
            dataManager.deleteActivity(activity)
        }
    }
}

struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity Icon
            Image(systemName: activity.type.icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            // Activity Info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(activity.type.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    if let duration = activity.duration {
                        Text("\(Int(duration / 60)) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(activity.date, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ActivityDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var activity: Activity
    @State private var showingEditActivity = false
    
    init(activity: Activity) {
        _activity = State(initialValue: activity)
    }
    
    var client: Client? {
        guard let clientId = activity.clientId else { return nil }
        return dataManager.clients.first { $0.id == clientId }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: activity.type.icon)
                            .foregroundColor(.blue)
                            .font(.title)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activity.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(activity.type.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Text(activity.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Activity Details
                    VStack(spacing: 8) {
                        DetailRow(icon: "calendar", title: "Fecha", value: activity.date, style: .date)
                        DetailRow(icon: "clock", title: "Hora", value: activity.date, style: .time)
                        
                        if let duration = activity.duration {
                            DetailRow(icon: "timer", title: "Duración", value: "\(Int(duration / 60)) minutos")
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Client Info (if associated)
                if let client = client {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cliente Asociado")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(client.name.prefix(1)))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(client.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(client.company)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Detalle Actividad")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") {
                    showingEditActivity = true
                }
            }
        }
        .sheet(isPresented: $showingEditActivity) {
            EditActivityView(activity: $activity)
        }
    }
}

#Preview {
    ActivitiesView()
        .environmentObject(DataManager())
}
