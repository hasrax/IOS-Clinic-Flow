import Foundation


enum NotificationType: String {
    case queue, lab, payment, reminder, pharmacy, companion, system
}


struct AppNotification: Identifiable {
    let id: Int
    let type: NotificationType
    var read: Bool     
    let time: String
    let title: String
    let body: String    
    let action: String
}
