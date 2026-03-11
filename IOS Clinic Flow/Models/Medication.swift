import Foundation

struct Medication: Identifiable {
    importlet id = UUID()
    let name: String
    let dosage: String
    let price: Int
    let prescribedBy: String
    let instructions: String
    let schedule: [String]
    let warnings: [String]
}

struct PharmacyOrder: Identifiable {
    let id: String
    let date: String
    let doctor: String
    let medications: [Medication]
    let status: String
    var isPaid: Bool

    // total cost — sums price × quantity for all medications
    var total: Int {
        medications.reduce(0) { $0 + ($1.price * $1.quantity) }
    }
}
