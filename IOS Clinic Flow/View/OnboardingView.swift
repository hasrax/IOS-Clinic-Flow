import SwiftUI

struct Onboarding_Slide {
    let title: String
    let highlight: String
    let subtitle: String
    let pills: [(icon: String, label: String, color: Color)]
}

struct OnboardingView: View {
    @State private var current_Page = 0
    @State private var isFinished = false
    
    let slides: [Onboarding_Slide] = [
            Onboarding_Slide(
                title: "Book Appointments ",
                highlight: "Effortlessly",
                subtitle: "Schedule your clinic visits in seconds.\nChoose your doctor, pick a time and skip the long queues",
                pills: [
                    ("house.fill", "Book Now", .successGreen),
                    ("clock.fill", "2.30 am", .warningAmber),
                ]
            ),
            Onboarding_Slide(
                title: "Navigate the Clinic ",
                highlight: "With Ease",
                subtitle: "Interactive indoor maps guide you to the right room, lab or pharmacy. no more getting lost",
                pills: [
                    ("flask.fill", "Lab", .primaryBlue),
                    ("mappin.circle.fill", "Room 230", .primaryBlue),
                ]
            ),
            Onboarding_Slide(
                title: "Track Your Visit in ",
                highlight: "Real Time",
                subtitle: "See your queue position, get alerts when it's your turn, and manage payments. all from your phone",
                pills: [
                    ("checkmark.circle.fill", "Your Turn", .successGreen),
                    ("person.3.fill", "In Queue", .primaryBlue),
                    ("creditcard.fill", "Pay Online", .primaryBlue),
                ]
            ),
        ]
}
