import Foundation
import SwiftUI

// MARK: - Settings Store
final class SettingsStore: ObservableObject {
    @Published var settings: AppSettings
    private let key = "AppSettings.v1"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .init(
                profile: .init(firstName: "", lastName: "", email: ""),
                payment: .init(method: "Tarjeta", gatewayEnabled: false),
                onboardingQuestions: "",
                feedback: ""
            )
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(settings) { 
            UserDefaults.standard.set(data, forKey: key) 
        }
    }
}
