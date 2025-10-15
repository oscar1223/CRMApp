import Foundation

// MARK: - Event Model
struct MockEvent: Identifiable, Codable {
    let id: UUID
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool

    init(id: UUID = UUID(), title: String, startDate: Date, endDate: Date, isAllDay: Bool = false) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
    }
}
