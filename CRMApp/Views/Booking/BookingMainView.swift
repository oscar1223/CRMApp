import SwiftUI

// MARK: - Booking Main View
struct BookingMainView: View {
    @State private var selectedRange: RevenueRange = .last30
    @State private var revenuePoints: [RevenuePoint] = RevenuePoint.mockLast30
    @State private var clients: [Client] = Client.mock
    
    private var totalRevenue: Double {
        revenuePoints.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                revenueSection
                clientsSection
            }
            .modernPadding(.horizontal, .small)
            .modernPadding(.vertical, .small)
        }
        .navigationTitle("Reservas")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Analítica de Reservas")
                    .modernText(size: .headline, color: .textPrimary)
                    .fontWeight(.bold)
                Text("Visualiza tu facturación y clientes")
                    .modernText(size: .subhead, color: .textSecondary)
            }
            Spacer()
        }
        .modernCard()
    }
    
    private var revenueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Facturación")
                    .modernText(size: .body, color: .textPrimary)
                    .fontWeight(.bold)
                Spacer()
                Picker("Rango", selection: $selectedRange) {
                    ForEach(RevenueRange.allCases, id: \.self) { range in
                        Text(range.title).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedRange) { oldValue, newValue in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        revenuePoints = newValue.points
                    }
                }
            }
            
            LineChart(points: revenuePoints)
                .frame(height: 180)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.backgroundSecondary)
                )
            
            HStack(spacing: 12) {
                metricCard(title: "Total", value: totalRevenue, format: .currency(code: "EUR"))
                metricCard(title: "Clientes", value: Double(clients.count), format: .number)
            }
        }
        .modernCard()
    }
    
    private func metricCard<F: Foundation.FormatStyle>(title: String, value: Double, format: F) -> some View where F.FormatInput == Double, F.FormatOutput == String {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .modernText(size: .caption, color: .textSecondary)
            Text(value, format: format)
                .modernText(size: .headline, color: .brandPrimary)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.backgroundTertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.borderLight, lineWidth: 1)
                )
        )
    }
    
    private var clientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Clientes")
                    .modernText(size: .body, color: .textPrimary)
                    .fontWeight(.bold)
                Spacer()
                Button("Añadir Cliente de Prueba") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        clients.insert(
                            Client(name: "Nuevo Cliente", email: "nuevo@example.com", phone: "+34 655 555 555", totalSpent: Double.random(in: 100...1500)),
                            at: 0
                        )
                    }
                }
                .modernButton(style: .secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(clients) { client in
                    ClientRow(client: client)
                }
            }
        }
        .modernCard()
    }
}

// MARK: - Line Chart
private struct LineChart: View {
    let points: [RevenuePoint]
    
    var body: some View {
        GeometryReader { geo in
            let maxAmount = max(points.map { $0.amount }.max() ?? 1, 1)
            let stepX = points.count > 1 ? geo.size.width / CGFloat(points.count - 1) : 0
            
            ZStack {
                // Baseline grid
                VStack { Spacer() }.frame(height: 1).frame(maxHeight: .infinity).background(Color.borderLight)
                
                Path { path in
                    guard let first = points.first else { return }
                    let startY = geo.size.height - CGFloat(first.amount / maxAmount) * geo.size.height
                    path.move(to: CGPoint(x: 0, y: startY))
                    for (index, point) in points.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = geo.size.height - CGFloat(point.amount / maxAmount) * geo.size.height
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.brandPrimary, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                
                // Gradient under area
                LinearGradient(colors: [Color.brandPrimary.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom)
                    .mask(
                        Path { path in
                            guard let first = points.first else { return }
                            let startY = geo.size.height - CGFloat(first.amount / maxAmount) * geo.size.height
                            path.move(to: CGPoint(x: 0, y: startY))
                            for (index, point) in points.enumerated() {
                                let x = CGFloat(index) * stepX
                                let y = geo.size.height - CGFloat(point.amount / maxAmount) * geo.size.height
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                            path.addLine(to: CGPoint(x: 0, y: geo.size.height))
                            path.closeSubpath()
                        }
                    )
            }
        }
    }
}

// MARK: - Client Row
private struct ClientRow: View {
    let client: Client
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.brandPrimary.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(initials(from: client.name))
                        .modernText(size: .subhead, color: .brandPrimary)
                        .fontWeight(.bold)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(client.name)
                    .modernText(size: .body, color: .textPrimary)
                    .fontWeight(.semibold)
                Text(client.email)
                    .modernText(size: .caption, color: .textSecondary)
            }
            Spacer()
            Text(client.totalSpent, format: .currency(code: "EUR"))
                .modernText(size: .subhead, color: .textPrimary)
                .fontWeight(.bold)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.borderLight, lineWidth: 1)
                )
        )
    }
    
    private func initials(from name: String) -> String {
        let comps = name.split(separator: " ")
        let first = comps.first?.first.map(String.init) ?? "C"
        let last = comps.dropFirst().first?.first.map(String.init) ?? "P"
        return first + last
    }
}

// MARK: - Revenue Models
private struct RevenuePoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let amount: Double
}

private enum RevenueRange: CaseIterable, Hashable, Identifiable {
    case last7, last30, last90
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .last7: return "7d"
        case .last30: return "30d"
        case .last90: return "90d"
        }
    }
    
    var points: [RevenuePoint] {
        switch self {
        case .last7: return RevenuePoint.mockLast7
        case .last30: return RevenuePoint.mockLast30
        case .last90: return RevenuePoint.mockLast90
        }
    }
}

private extension RevenuePoint {
    static var mockLast7: [RevenuePoint] { Self.generate(days: 7) }
    static var mockLast30: [RevenuePoint] { Self.generate(days: 30) }
    static var mockLast90: [RevenuePoint] { Self.generate(days: 90) }
    
    static func generate(days: Int) -> [RevenuePoint] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<days).map { i in
            let date = cal.date(byAdding: .day, value: -((days - 1) - i), to: today) ?? today
            let base = 80.0 + Double(i % 7) * 15.0
            let random = Double(Int.random(in: 0...30))
            return RevenuePoint(date: date, amount: base + random)
        }
    }
}


