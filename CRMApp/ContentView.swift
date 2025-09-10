import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .environmentObject(dataManager)
            
            ClientsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Clientes")
                }
                .environmentObject(dataManager)
            
            TasksView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Tareas")
                }
                .environmentObject(dataManager)
            
            ActivitiesView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Actividades")
                }
                .environmentObject(dataManager)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
