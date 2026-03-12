import Foundation

struct MockAppointments {
    static let current = Appointment(
        id: "BM240126-11",
        doctor: MockDoctors.all[0],
        date: "Feb 23, 2026",
        time: "2:30 PM",
        status: .active,
        location: "Room 204, Floor 2",
        token: "BM240126-11",
        queuePosition: 3,
        estimatedWait: "~15 min",
        patientName: "Malini Hasra",
        reason: "General checkup",
        totalCost: 3250,
        costs: [
            CostItem(label: "Consultation Fee", amount: 1500),
            CostItem(label: "Lab — CBC Test", amount: 500),
            CostItem(label: "Lab — Lipid Profile", amount: 300),
            CostItem(label: "Pharmacy — 3 medications", amount: 850),
            CostItem(label: "Service Charge", amount: 100),
        ],
        steps: ["Registration", "Consultation", "Lab Tests (2)", "Pharmacy", "Payment"],
        cancelReason: nil,
        refunded: false
    )
    //fake appointment data used to add to the appointment parts

    static let history: [Appointment] = [
        current,
        Appointment(
            id: "BM260215-08", doctor: MockDoctors.all[1],
            date: "Feb 15, 2026", time: "10:00 AM", status: .completed,
            location: "Building B, Floor 2", token: "BM260215-08",
            totalCost: 3220,
            costs: [
                CostItem(label: "Consultation Fee", amount: 2000),
                CostItem(label: "Lab — Blood Glucose", amount: 500),
                CostItem(label: "Pharmacy — 2 medications", amount: 620),
                CostItem(label: "Service Charge", amount: 100),
            ],
            steps: ["Registration", "Consultation", "Lab Test", "Pharmacy", "Payment"],
            cancelReason: nil, refunded: false
        ),
        Appointment(
            id: "BM260210-15", doctor: MockDoctors.all[2],
            date: "Feb 10, 2026", time: "9:00 AM", status: .cancelled,
            location: "Room 105, Floor 1", token: "BM260210-15",
            totalCost: 1900,
            costs: [
                CostItem(label: "Consultation Fee", amount: 1800),
                CostItem(label: "Service Charge", amount: 100),
            ],
            steps: [],
            cancelReason: "Doctor unavailable", refunded: true
        ),
        Appointment(
            id: "BM260220-07", doctor: MockDoctors.all[3],
            date: "Feb 20, 2026", time: "11:00 AM", status: .scheduled,
            location: "Room 9N, Floor 1", token: "BM260220-07",
            totalCost: 2500,
            costs: [CostItem(label: "Consultation Fee", amount: 2500)],
            steps: [],
            cancelReason: nil, refunded: false
        ),
        Appointment(
            id: "BM260226-03", doctor: MockDoctors.all[0],
            date: "Feb 26, 2026", time: "2:30 PM", status: .scheduled,
            location: "Room 89B, Floor 3", token: "BM260226-03",
            totalCost: 1500,
            costs: [CostItem(label: "Consultation Fee", amount: 1500)],
            steps: [],
            cancelReason: nil, refunded: false
        ),
    ]

    // All appointments used by CalendarView (history + future scheduled)
    static var calendarAppointments: [Appointment] { history }
//mock appointment histroy data to be used because stuff is static my guy
    static let currentQueue = QueueData(
        position: 3,
        totalInQueue: 8,
        estimatedWait: "~15 min",
        roomNumber: "Room 204, Floor 2",
        doctor: MockDoctors.all[0],
        steps: [
            VisitStep(label: "Registration", status: .done, estimatedTime: "1:45 PM"),
            VisitStep(label: "Consultation", status: .active, estimatedTime: "~2:30 PM"),
            VisitStep(label: "Lab Tests", status: .pending, estimatedTime: "~2:45 PM"),
            VisitStep(label: "Pharmacy", status: .pending, estimatedTime: "~3:20 PM"),
            VisitStep(label: "Payment", status: .pending, estimatedTime: "~3:30 PM"),
        ]
    )
}
//quque data that mock because staticnes is real
