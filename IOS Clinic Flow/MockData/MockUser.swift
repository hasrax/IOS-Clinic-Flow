import Foundation

<<<<<<< HEAD
//these are the data using for companion, notifications, and also the current profile
=======
>>>>>>> lakindu-dev
struct MockUser {
    static let current = Patient(
        name: "Malini Hasra",
        phone: "+94 77 123 4567",
        bloodType: "O+",
        age: 34,
        weight: "72 kg",
        height: "175 cm",
        initials: "MH"
    )

    static let notifications: [AppNotification] = [
        AppNotification(id: 1, type: .queue, read: false, time: "2 min ago",
            title: "Your turn is approaching!",
            body: "You are 3rd in queue for Dr. Samantha Perera. Please stay nearby.",
            action: "queue"),
        AppNotification(id: 2, type: .lab, read: false, time: "10 min ago",
            title: "Lab results are ready",
            body: "Your Urinalysis (LAB-0088) results are now available to view.",
            action: "lab"),
        AppNotification(id: 3, type: .payment, read: false, time: "1 hr ago",
            title: "Payment confirmed — LKR 1,500",
            body: "Consultation fee for Dr. Samantha Perera has been processed.",
            action: "payment"),
        AppNotification(id: 4, type: .reminder, read: true, time: "2 hrs ago",
            title: "Appointment reminder — Tomorrow",
            body: "Dr. Nimal Fernando · Cardiology · 10:00 AM · Building B, Floor 2",
            action: "home"),
    ]

    static let companions: [CareForPerson] = [
        CareForPerson(
            id: 1, name: "Amal Perera", relation: "Father", age: 68,
            phone: "+94 71 234 5678", avatar: "👴",
            conditions: ["Diabetes", "Hypertension"],
            lastVisit: "Feb 20, 2026",
            upcomingAppt: UpcomingAppointment(
                doctor: "Dr. Nimal Fernando", specialty: "Cardiology",
                date: "Feb 25, 2026", time: "10:00 AM",
                location: "Building B, Floor 2", token: "#A-0251"
            ),
            queueData: CompanionQueueData(
                position: 5, doctor: "Dr. Nimal Fernando",
                room: "Room 301, Floor 3", estimatedWait: "~25 min",
                currentStep: "Waiting for consultation",
                steps: [
<<<<<<< HEAD
                                    VisitStep(label: "Registration", status: .done, estimatedTime: "9:30 AM"),
                                    VisitStep(label: "Vitals Check", status: .done, estimatedTime: "9:45 AM"),
                                    VisitStep(label: "Consultation", status: .active, estimatedTime: "~10:00 AM"),
                                    VisitStep(label: "Lab Tests", status: .pending, estimatedTime: "~10:30 AM"),
                                    VisitStep(label: "Payment", status: .pending, estimatedTime: "~11:15 AM"),
                                ]
=======
                    VisitStep(label: "Registration", status: .done, estimatedTime: "9:30 AM"),
                    VisitStep(label: "Vitals Check", status: .done, estimatedTime: "9:45 AM"),
                    VisitStep(label: "Consultation", status: .active, estimatedTime: "~10:00 AM"),
                    VisitStep(label: "Lab Tests", status: .pending, estimatedTime: "~10:30 AM"),
                    VisitStep(label: "Payment", status: .pending, estimatedTime: "~11:15 AM"),
                ]
>>>>>>> lakindu-dev
            ),
            alerts: [
                CompanionAlert(id: 1, text: "Queue position changed to 5th", time: "5 min ago", type: "queue"),
                CompanionAlert(id: 2, text: "Registration completed", time: "30 min ago", type: "step"),
            ]
        ),
        CareForPerson(
            id: 2, name: "Vihanga", relation: "Sister", age: 14,
            phone: "+94 77 456 7890", avatar: "👧",
            conditions: ["Asthma"],
            lastVisit: "Jan 15, 2026",
            upcomingAppt: nil, queueData: nil,
            alerts: [
                CompanionAlert(id: 1, text: "Lab results ready — Spirometry Test", time: "3 days ago", type: "lab"),
            ]
        ),
    ]
}
<<<<<<< HEAD
=======
//detail;s about the users and stuff
>>>>>>> lakindu-dev
