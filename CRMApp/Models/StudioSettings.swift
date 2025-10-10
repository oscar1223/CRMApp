import Foundation
import SwiftData

// MARK: - Studio Settings Model
@Model
class StudioSettings {
    var id: UUID
    var studioName: String
    var address: String
    var phone: String
    var email: String
    var website: String
    var studioDescription: String

    // Business hours
    var openTime: Date
    var closeTime: Date
    var workingDays: [Int] // 0 = Sunday, 6 = Saturday

    // Booking settings
    var requireDeposit: Bool
    var defaultDepositPercentage: Double
    var allowOnlineBooking: Bool
    var autoConfirmBookings: Bool
    var cancellationHours: Int

    // Payment settings
    var acceptCash: Bool
    var acceptCard: Bool
    var acceptTransfer: Bool
    var taxRate: Double

    // Notifications
    var notifyNewBooking: Bool
    var notifyDayBefore: Bool
    var notifyHourBefore: Bool
    var emailNotifications: Bool
    var smsNotifications: Bool

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        studioName: String = "Mi Estudio",
        address: String = "",
        phone: String = "",
        email: String = "",
        website: String = "",
        studioDescription: String = "",
        openTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date(),
        closeTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
        workingDays: [Int] = [1, 2, 3, 4, 5, 6], // Monday to Saturday
        requireDeposit: Bool = true,
        defaultDepositPercentage: Double = 20.0,
        allowOnlineBooking: Bool = true,
        autoConfirmBookings: Bool = false,
        cancellationHours: Int = 24,
        acceptCash: Bool = true,
        acceptCard: Bool = true,
        acceptTransfer: Bool = true,
        taxRate: Double = 21.0,
        notifyNewBooking: Bool = true,
        notifyDayBefore: Bool = true,
        notifyHourBefore: Bool = false,
        emailNotifications: Bool = true,
        smsNotifications: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.studioName = studioName
        self.address = address
        self.phone = phone
        self.email = email
        self.website = website
        self.studioDescription = studioDescription
        self.openTime = openTime
        self.closeTime = closeTime
        self.workingDays = workingDays
        self.requireDeposit = requireDeposit
        self.defaultDepositPercentage = defaultDepositPercentage
        self.allowOnlineBooking = allowOnlineBooking
        self.autoConfirmBookings = autoConfirmBookings
        self.cancellationHours = cancellationHours
        self.acceptCash = acceptCash
        self.acceptCard = acceptCard
        self.acceptTransfer = acceptTransfer
        self.taxRate = taxRate
        self.notifyNewBooking = notifyNewBooking
        self.notifyDayBefore = notifyDayBefore
        self.notifyHourBefore = notifyHourBefore
        self.emailNotifications = emailNotifications
        self.smsNotifications = smsNotifications
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var openTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: openTime)
    }

    var closeTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: closeTime)
    }

    var workingDaysText: String {
        let dayNames = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
        return workingDays.sorted().map { dayNames[$0] }.joined(separator: ", ")
    }
}

// MARK: - Personal Settings Extensions
extension StudioSettings {
    static var defaultPersonal: StudioSettings {
        StudioSettings(
            studioName: "Mi Perfil",
            requireDeposit: false,
            defaultDepositPercentage: 0,
            allowOnlineBooking: false,
            autoConfirmBookings: true
        )
    }
}
