import Foundation

enum StepStatus: String {
    case done, active, pending
}

struct VisitStep: Identifiable {
    let id = UUID()
    let label: String
    let status: StepStatus
    let estimatedTime: String
}

struct QueueData: Identifiable {
    let id = UUID()
    let position: Int
    let totalInQueue: Int
    let estimatedWait: String
    let roomNumber: String
    let doctor: Doctor
    let steps: [VisitStep]
}

//information regarding the queue
