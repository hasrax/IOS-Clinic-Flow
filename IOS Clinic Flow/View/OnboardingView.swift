import SwiftUI

struct Onboarding_Slide {
    let title: String
    let highlight: String
    let subtitle: String
    let pills: [(icon: String, label: String, color: Color)]
}

// Main onboarding screen
struct OnboardingView: View {
    @State private var current_Page = 0  // Tracks which onboarding page is currently shown
    @State private var isFinished = false // Controls navigation to the next screen
    
    // Array containing all onboarding slides
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
    
    var body: some View {
            if isFinished {
                LanguageView()
            } else {
                ZStack {
                    Color.appBackground
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        // Skip button section
                        HStack {
                            Spacer()
                            Button("skip") {
                                isFinished = true
                            }
                            .font(.custom("Inter_18pt-Medium", size: 15))
                            .foregroundColor(.primaryBlue)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }

                        // Illustration area
                        ZStack {
                            // Outer background circle
                            Circle()
                                .fill(Color(hex: "E2E6EE"))
                                .frame(width: 270, height: 270)

                            // Inner background circle
                            Circle()
                                .fill(Color(hex: "D0D8EA"))
                                .frame(width: 190, height: 190)

                            // Main illustration changes depending on current page
                            IllustrationView(slideIndex: current_Page)

                            // Floating pills also change depending on current page
                            FloatingPillsView(pills: slides[current_Page].pills, slideIndex: current_Page)
                        }
                        .frame(width: 340, height: 320)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)

                        // Text content area
                        VStack(spacing: 10) {
                            HStack(spacing: 0) {
                                
                                // Normal title text
                                Text(slides[current_Page].title)
                                    .font(.custom("Inter_18pt-Bold", size: 24))
                                    .foregroundColor(.textPrimary)
                                
                                // Highlighted title text
                                Text(slides[current_Page].highlight)
                                    .font(.custom("Inter_18pt-Bold", size: 24))
                                    .foregroundColor(.primaryBlue)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            
                            // Subtitle
                            Text(slides[current_Page].subtitle)
                                .font(.custom("Inter_18pt-Regular", size: 14))
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                                .padding(.horizontal, 36)
                                .padding(.top, 35)
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 50)
                        .padding(.bottom, 20)

                        Spacer()

                        // Page indicator dots
                        HStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(i == current_Page ? Color.primaryBlue : Color(hex: "C4CBD8"))
                                    .frame(width: i == current_Page ? 10 : 7,
                                           height: i == current_Page ? 10 : 7)
                                    .animation(.easeInOut(duration: 0.2), value: current_Page)
                            }
                        }
                        .padding(.bottom, 32)

                        // Bottom navigation arrows
                        HStack {
                            // Back arrow button
                            Button {
                                if current_Page > 0 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        current_Page -= 1 // Go to previous slide
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(current_Page > 0 ? .primaryBlue : .clear)
                            }
                            .padding(.leading, 32)

                            Spacer()

                            // Next arrow button
                            Button {
                                if current_Page < 2 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        current_Page += 1 // Go to next slide
                                    }
                                } else {
                                    isFinished = true // If last slide, finish onboarding
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primaryBlue)
                            }
                            .padding(.trailing, 32)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
}

//Illustration View
// show a different center illustration depending on the page
struct IllustrationView: View {
    let slideIndex: Int

    var body: some View {
        switch slideIndex {
        case 0, 2:
            Image("onboarding1")
                .resizable()
                .scaledToFill()
                .frame(width: 186, height: 186)
                .clipShape(Circle())
        case 1:
            // Keep SwiftUI illustration
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.primaryBlue)
                Ellipse()
                    .fill(Color.primaryBlue.opacity(0.15))
                    .frame(width: 60, height: 12)
                    .padding(.top, 4)
            }
        default:
            EmptyView()
        }
    }
}


//Floating Pills
//animated pills around the illustration
struct FloatingPillsView: View {
    let pills: [(icon: String, label: String, color: Color)]
    let slideIndex: Int
    @State private var show = false

    var body: some View {
        ZStack {
            switch slideIndex {
            case 0:
                // First pill for slide 0
                PillBadge(icon: pills[0].icon, label: pills[0].label, color: pills[0].color)
                    .offset(x: 80, y: -100)
                    .opacity(show ? 1 : 0)
                    .scaleEffect(show ? 1 : 0.6)
                    .animation(.spring(response: 0.45, dampingFraction: 0.65).delay(0.1), value: show)
                // Second pill for slide 0
                PillBadge(icon: pills[1].icon, label: pills[1].label, color: pills[1].color)
                    .offset(x: -70, y: 80)
                    .opacity(show ? 1 : 0)
                    .scaleEffect(show ? 1 : 0.6)
                    .animation(.spring(response: 0.45, dampingFraction: 0.65).delay(0.25), value: show)

            case 1:
                // First pill for slide 1
                PillBadge(icon: pills[0].icon, label: pills[0].label, color: pills[0].color)
                    .offset(x: -80, y: -80)
                    .opacity(show ? 1 : 0)
                    .scaleEffect(show ? 1 : 0.6)
                    .animation(.spring(response: 0.45, dampingFraction: 0.65).delay(0.1), value: show)
                // Second pill for slide 1
                PillBadge(icon: pills[1].icon, label: pills[1].label, color: pills[1].color)
                    .offset(x: 70, y: 90)
                    .opacity(show ? 1 : 0)
                    .scaleEffect(show ? 1 : 0.6)
                    .animation(.spring(response: 0.45, dampingFraction: 0.65).delay(0.25), value: show)

            case 2:
                // First pill for slide 2
                PillBadge(icon: pills[0].icon, label: pills[0].label, color: pills[0].color)
                    .offset(x: 70, y: -100)
                    .opacity(show ? 1 : 0)
                    .scaleEffect(show ? 1 : 0.6)
                    .animation(.spring(response: 0.45, dampingFraction: 0.65).delay(0.1), value: show)
                // Second pill for slide 2
                PillBadge(icon: pills[1].icon, label: pills[1].label, color: pills[1].color)
                    .offset(x: -80, y: 20)
                    .opacity(show ? 1 : 0)
                    .scaleEffect(show ? 1 : 0.6)
                    .animation(.spring(response: 0.45, dampingFraction: 0.65).delay(0.2), value: show)
                // Third pill for slide 2
                PillBadge(icon: pills[2].icon, label: pills[2].label, color: pills[2].color)
                    .offset(x: 75, y: 90)
                    .opacity(show ? 1 : 0)
                    .scaleEffect(show ? 1 : 0.6)
                    .animation(.spring(response: 0.45, dampingFraction: 0.65).delay(0.3), value: show)

            default:
                EmptyView()
            }
        }
        .onAppear {
            show = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                show = true
            }
        }
    }
}

// Single pill badge design
struct PillBadge: View {
    let icon: String
    let label: String
    let color: Color
    @State private var isFloating = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
            Text(label)
                .font(.custom("Inter_18pt-SemiBold", size: 12))
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .offset(y: isFloating ? -5 : 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
    }
}
