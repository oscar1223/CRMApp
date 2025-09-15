import Foundation

// MARK: - App Settings Model
struct AppSettings: Codable, Hashable {
    struct Profile: Codable, Hashable { 
        var firstName: String
        var lastName: String
        var email: String
    }
    
    struct Payment: Codable, Hashable { 
        var method: String
        var gatewayEnabled: Bool
    }
    
    var profile: Profile
    var payment: Payment
    var onboardingQuestions: String
    var feedback: String
}
