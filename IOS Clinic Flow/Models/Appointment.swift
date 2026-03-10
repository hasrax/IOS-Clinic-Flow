import Foundation

enum AppointmentStatus: String {
    case active, scheduled, completed, cancelled
}

struct Appointment: Identifiable {
    let id: String
    let doctor: Doctor
    let date: String
    let time: String
    let status: AppointmentStatus
    let location: String
    let token: String
    var queuePosition: Int?
    var estimatedWait: String?
    var patientName: String?
    var reason: String?
    var totalCost: Int?
    var costs: [CostItem]
    var steps: [String]
    var cancelReason: String?
    var refunded: Bool
}

struct CostItem: Identifiable {
    let id = UUID()
    let label: String
    let amount: Int
}
//details on what appointments are happening when and whats going on
