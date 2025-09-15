import Foundation

// MARK: - Client Model
struct Client: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var phone: String
    var notes: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, email: String, phone: String, notes: String = "") {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.notes = notes
        self.createdAt = Date()
    }
}

// MARK: - Booking Link Model
struct BookingLink: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var url: String
    
    init(id: UUID = UUID(), title: String, url: String) {
        self.id = id
        self.title = title
        self.url = url
    }
}

// MARK: - Blackout Range Model
struct BlackoutRange: Codable, Hashable {
    let startDate: Date
    let endDate: Date
    let isos: [String] // ISO date strings for this range
    
    var isSingleDay: Bool {
        Calendar.current.isDate(startDate, inSameDayAs: endDate)
    }
    
    var displayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("d 'de' MMMM")
        
        if isSingleDay {
            return formatter.string(from: startDate)
        } else {
            let startText = formatter.string(from: startDate)
            let endText = formatter.string(from: endDate)
            return "\(startText) - \(endText)"
        }
    }
}
