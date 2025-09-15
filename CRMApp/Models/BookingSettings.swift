import Foundation

// MARK: - Weekly Availability Model
struct WeeklyAvailability: Codable, Hashable {
    struct Day: Codable, Hashable { 
        var enabled: Bool
        var start: Date
        var end: Date
    }
    var days: [Int: Day] // 1..7 (Mon..Sun per ISO)
}

// MARK: - Studio Info Model
struct StudioInfo: Codable, Hashable { 
    var name: String
    var location: String
}

// MARK: - Booking Settings Model
struct BookingSettings: Codable, Hashable {
    var links: [BookingLink]
    var availability: WeeklyAvailability
    var studio: StudioInfo
    var blackoutDates: Set<String> // yyyy-MM-dd
    var reminders24h: Bool
}
