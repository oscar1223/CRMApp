import Foundation
import SwiftUI

// MARK: - Booking Store
final class BookingStore: ObservableObject {
    @Published var settings: BookingSettings
    private let key = "BookingSettings.v1"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(BookingSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = BookingStore.defaultSettings()
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func defaultSettings() -> BookingSettings {
        let calendar = Calendar(identifier: .iso8601)
        var days: [Int: WeeklyAvailability.Day] = [:]
        for i in 1...7 {
            let start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
            let end = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
            days[i] = WeeklyAvailability.Day(enabled: i <= 5, start: start, end: end)
        }
        let availability = WeeklyAvailability(days: days)
        let links = [
            BookingLink(title: "Reserva General", url: "https://example.com/reserva/general"),
            BookingLink(title: "Consulta Inicial", url: "https://example.com/reserva/consulta")
        ]
        let studio = StudioInfo(name: "Mi Estudio", location: "Calle Principal 123, Ciudad")
        return BookingSettings(links: links, availability: availability, studio: studio, blackoutDates: [], reminders24h: true)
    }
}
