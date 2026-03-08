import Foundation

enum LabResultStatus: String{
    case normal
    case high
    case low
}

struct LabResultRow: Identifiable {
    let id = UUID()
    let testName: String
    let value: String
    let referenceRange: String
    let status: LabResultStatus
}

struct LabReport: Identifiable {
    let id: String
    let testName: String
    let date: String         //
    let doctor: String       //
    let status: String       //
    let nurseRoom: String    //
    let time: String         //
    var results: [LabResultRow]  //
    var doctorNotes: String      //
    var isPaid: Bool             // 
}
