import Foundation

// MARK: - Event Model
struct MockEvent: Identifiable, Codable {
    var id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    
    init(title: String, startDate: Date, endDate: Date, isAllDay: Bool = false) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
    }
}
