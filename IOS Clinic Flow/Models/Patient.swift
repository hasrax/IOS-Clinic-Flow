import Foundation

// Model representing a patient in the app
struct Patient: Identifiable {
    let id = UUID()
    var name: String
    var phone: String
    var bloodType: String
    var age: Int
    var weight: String
    var height: String
    var initials: String
}

