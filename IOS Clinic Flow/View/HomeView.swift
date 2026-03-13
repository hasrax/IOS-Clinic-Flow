import SwiftUI
internal import Combine

final class AppRouter: ObservableObject {
    static let shared = AppRouter()
    private init() {}
    @Published var isLoggedIn: Bool = false
    @Published var pendingTab: TabItem? = nil
    @Published var activeTab: TabItem = .home
    @Published var loggedInPhone: String = ""
    @Published var isNewUser: Bool = false
}

struct HomeView: View {
    @State private var isFirstUser: Bool
    @State private var selectedTab: TabItem = .home
    @State private var showBookingSearch = false
    @State private var showNotifications = false
    @State private var showMap = false
    @State private var showLab = false
    @State private var showPharmacy = false
    @State private var showCompanion = false
    @State private var showQueueStatus = false
    @State private var showPayment = false
    @State private var showEditProfile = false
    @State private var showCalendar = false
    @State private var newUserName = ""
    @State private var newUserPhone = ""
//Boolean Flags which are user to navigate to different places when toggled to true
    init(isReturningUser: Bool = false) {
        _isFirstUser = State(initialValue: !isReturningUser)
    } //this is the part we used to initialize and decide what and who the user is since its a static front end

    var body: some View {
        NavigationStack { //manages screen to screen navigation
            ZStack {
                Color(hex: "EEF1F5") //bavkground color
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Scrollable content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Header — same for both
                            HomeHeaderView(showNotifications: $showNotifications) //show notification is set as a two way binding here
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                                .padding(.bottom, 16)
//Decides if its a first time user or not and sets settings accordingly xxxx
                            if isFirstUser {
                                FirstUserContent(
                                    isFirstUser: $isFirstUser,
                                    showBookingSearch: $showBookingSearch,
                                    showEditProfile: $showEditProfile,
                                    onMap: { showMap = true },
                                    onLab: { showLab = true },
                                    onPharmacy: { showPharmacy = true },
                                    onCompanion: { showCompanion = true }
                                )
                            } else {
                                ReturningUserContent(
                                    showBookingSearch: $showBookingSearch,
                                    onMap: { showMap = true },
                                    onLab: { showLab = true },
                                    onPharmacy: { showPharmacy = true },
                                    onCompanion: { showCompanion = true },
                                    onQueueTap: { showQueueStatus = true },
                                    onPay: { showPayment = true },
                                    onCalendar: { showCalendar = true }
                                )
                            }

                            Spacer().frame(height: 100)
                        }
                    }

                    // Tab Bar
                    BottomTabBar(selectedTab: $selectedTab)
                }
                
                //navigations to each and every location (view the green words to see where XD
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(isPresented: $showBookingSearch) {
                BookingSearchView()
            }
            .navigationDestination(isPresented: $showNotifications) {
                NotificationsView()
            }
            .navigationDestination(isPresented: $showMap) {
                ClinicMapView()
            }
            .navigationDestination(isPresented: $showLab) {
                LabView()
            }
            .navigationDestination(isPresented: $showPharmacy) {
                PharmacyView()
            }
            .navigationDestination(isPresented: $showCompanion) {
                CompanionView()
            }
            .navigationDestination(isPresented: $showQueueStatus) {
                QueueStatusView()
            }
            .navigationDestination(isPresented: $showPayment) {
                PaymentView(
                    doctor: MockDoctors.all[0],
                    selectedDate: Date(),
                    selectedTimeSlot: TimeSlot(time: "8.30 AM", bookedCount: 3, maxCount: 8),
                    totalAmount: 1600
                )
            }
            .navigationDestination(isPresented: $showEditProfile) {
                EditProfileView(name: $newUserName, phone: $newUserPhone)
            }
            .navigationDestination(isPresented: $showCalendar) {
                CalendarView()
            }
            .preferredColorScheme(.light)
            .onAppear {
                if AppRouter.shared.isNewUser && newUserPhone.isEmpty {
                    newUserPhone = "+94 \(AppRouter.shared.loggedInPhone)"
                }
            }
            .onChange(of: selectedTab) { _, newTab in
                if newTab != .home {
                    AppRouter.shared.pendingTab = newTab
                    selectedTab = .home
                } //used to switch back to home when needed when we move to a page thats not home
            }
        }
    }
}

// MARK: - Header (both screens)
struct HomeHeaderView: View {
    @Binding var showNotifications: Bool
    @ObservedObject private var router = AppRouter.shared

    var body: some View {
        HStack(spacing: 12) {
            Button { AppRouter.shared.pendingTab = .profile } label: {
                if router.isNewUser {
                    Circle()
                        .fill(Color(hex: "D8DCE6"))
                        .frame(width: 46, height: 46)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "8A93A6"))
                        )
                } else {
                    Image("malini_avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 46, height: 46)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Good Morning")
                    .font(.custom("Inter_18pt-Regular", size: 13))
                    .foregroundColor(.textSecondary)
                if router.isNewUser {
                    Text("+94 \(router.loggedInPhone)")
                        .font(.custom("Inter_18pt-Bold", size: 16))
                        .foregroundColor(.textPrimary)
                } else {
                    Text("Melisha Perera")
                        .font(.custom("Inter_18pt-Bold", size: 16))
                        .foregroundColor(.textPrimary)
                }
            }

            Spacer()

            // Bell with red dot
            ZStack(alignment: .topTrailing) {
                Button {
                    showNotifications = true
                } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.textPrimary)
                }
                Circle()
                    .fill(Color.errorRed)
                    .frame(width: 8, height: 8)
                    .offset(x: 2, y: -2)
            }
        }
    }
}

//if the person logging in is a first time user this defines their content and what they need to do
struct FirstUserContent: View {
    @Binding var isFirstUser: Bool
    @Binding var showBookingSearch: Bool
    @Binding var showEditProfile: Bool
    var onMap: () -> Void = {}
    var onLab: () -> Void = {}
    var onPharmacy: () -> Void = {}
    var onCompanion: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            // Welcome card
            GradientCard {
                VStack(spacing: 12) {
                    Text("WELCOME !")
                        .font(.custom("Inter_18pt-ExtraBold", size: 22))
                        .foregroundColor(.white)

                    Text("Your clinic visits just got easier. Book appointments,\nskip queues and navigate with ease")
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
//yap about the user
                    // White book button
                    Button {
                        showBookingSearch = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.primaryBlue)
                            Text("Book Your First Appointment")
                                .font(.custom("Inter_18pt-SemiBold", size: 14))
                                .foregroundColor(.primaryBlue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 4)
                }
                .padding(24)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

    //This shows the 6 quock actions buttons but with some options closed sincethis is for the first user
            QuickActionsGrid(
                firstUserMode: true,
                onBookNow: { showBookingSearch = true },
                onCompanion: { onCompanion() }
            )
            .padding(.bottom, 24)

           
            VStack(alignment: .leading, spacing: 12) {
                Text("Get started")
                    .font(.custom("Inter_18pt-Bold", size: 18))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 20)

                Button { showEditProfile = true } label: {
                    WhiteCard(cornerRadius: 16, padding: 16) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "E5E7EB"))
                                    .frame(width: 42, height: 42)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.textSecondary)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Complete Your Profile")
                                    .font(.custom("Inter_18pt-Bold", size: 15))
                                    .foregroundColor(.textPrimary)
                                Text("Add allergies, weight, height and\nemergency contact")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)

            // Did You Know card
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "F59E0B"))
                        .frame(width: 46, height: 46)
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Did You Know ?")
                        .font(.custom("Inter_18pt-Bold", size: 14))
                        .foregroundColor(.textPrimary)
                    Text("You can track your queue position in real time and get notified when it's your turn. No more waiting in the lobby !")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .background(Color(hex: "FFFBEB"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "F59E0B").opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            // Popular Specialties
            VStack(alignment: .leading, spacing: 14) {
                Text("Popular Specialties")
                    .font(.custom("Inter_18pt-Bold", size: 18))
                    .foregroundColor(.primaryBlue)
                    .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    SpecialtyCard(
                        image: "specialty_cardiology",
                        name: "Cardiologist",
                        count: "6 Doctors"
                    )
                    SpecialtyCard(
                        image: "specialty_neurology",
                        name: "Neurologists",
                        count: "2 Doctors"
                    )
                    SpecialtyCard(
                        image: "specialty_pulmonology",
                        name: "Pulmonologist",
                        count: "4 Doctors"
                    )
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
        }
    }
}

// If the user is a second or later time (returning user) this is the page to be shown
struct ReturningUserContent: View {
    @Binding var showBookingSearch: Bool
    var onMap: () -> Void = {}
    var onLab: () -> Void = {}
    var onPharmacy: () -> Void = {}
    var onCompanion: () -> Void = {}
    var onQueueTap: () -> Void = {}
    var onPay: () -> Void = {}
    var onCalendar: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            Button {
                showBookingSearch = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                        .foregroundColor(.textTertiary)
                    Text("search doctors , services.....")
                        .font(.custom("Inter_18pt-Regular", size: 14))
                        .foregroundColor(.textTertiary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Live Queue Card
            LiveQueueCard(onTap: onQueueTap)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

            // Quick Actions
            QuickActionsGrid(
                onBookNow: { showBookingSearch = true },
                onMap: onMap,
                onLab: onLab,
                onPharmacy: onPharmacy,
                onCompanion: onCompanion,
                onPay: onPay,
                onCalendar: onCalendar
            )
            .padding(.bottom, 24)

            // Appointments
            AppointmentsSection()
                .padding(.bottom, 24)

            // Health Summary
            HealthSummarySection()
                .padding(.bottom, 24)

            // Companion
            CompanionSection(onTap: onCompanion)
                .padding(.bottom, 24)

            // Calendar
            CalendarSection(onTap: onCalendar)
                .padding(.bottom, 24)
        }
    }
}

// grid with all the quick actions activated because its a returning user and they can have all the buttons active xxxx
struct QuickActionsGrid: View {
    var firstUserMode: Bool = false
    var onBookNow: () -> Void = {}
    var onMap: () -> Void = {}
    var onLab: () -> Void = {}
    var onPharmacy: () -> Void = {}
    var onCompanion: () -> Void = {}
    var onPay: () -> Void = {}
    var onCalendar: () -> Void = {}
//to show that its not a first user mode
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Quick Actions")
                    .font(.custom("Inter_18pt-Bold", size: 18))
                    .foregroundColor(.primaryBlue)
                Spacer()
                Button(action: onCalendar) {
                    Image(systemName: "calendar")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                        .frame(width: 32, height: 32)
                        .background(RoundedRectangle(cornerRadius: 9).fill(Color.primaryBlueTint))
                }
            }
            .padding(.horizontal, 20)

            // Row 1
            HStack(spacing: 12) {
                QuickActionButton(icon: "house.fill",     label: "Book Now",  iconColor: .primaryBlue,            bgColor: .primaryBlueTint,                  isEnabled: true,              action: onBookNow)
                QuickActionButton(icon: "map.fill",       label: "Map",       iconColor: Color(hex: "10B981"),    bgColor: Color(hex: "10B981").opacity(0.10), isEnabled: true,              action: onMap)
                QuickActionButton(icon: "flask.fill",     label: "Lab",       iconColor: .warningAmber,           bgColor: .warningTint,                      isEnabled: !firstUserMode,    action: onLab)
            }
            .padding(.horizontal, 20)

            // Row 2
            HStack(spacing: 12) {
                QuickActionButton(icon: "pill.fill",      label: "Pharmacy",  iconColor: .purpleAccent,           bgColor: .purpleTint,                       isEnabled: !firstUserMode,    action: onPharmacy)
                QuickActionButton(icon: "person.3.fill",  label: "Companion", iconColor: .errorRed,               bgColor: .errorTint,                        isEnabled: true,              action: onCompanion)
                QuickActionButton(icon: "creditcard.fill",label: "Pay",       iconColor: .cyanAccent,             bgColor: .cyanTint,                         isEnabled: !firstUserMode,    action: onPay)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let iconColor: Color
    let bgColor: Color
    var isEnabled: Bool = true
    var action: () -> Void = {}

    var body: some View {
        Button(action: isEnabled ? action : {}) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isEnabled ? bgColor : Color(hex: "F3F4F6"))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isEnabled ? iconColor : Color(hex: "C4C9D1"))
                }
                Text(label)
                    .font(.custom("Inter_18pt-Medium", size: 12))
                    .foregroundColor(isEnabled ? .textPrimary : .textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(isEnabled ? 0.03 : 0.01), radius: 4, x: 0, y: 2)
            .opacity(isEnabled ? 1.0 : 0.55)
        }
        .disabled(!isEnabled)
    }
} //to check if things as disabled or not and to officially enabke annd disabke the buttons and stuff

//card that shows the spacialities
struct SpecialtyCard: View {
    let image: String
    let name: String
    let count: String

    var body: some View {
        VStack(spacing: 8) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)

            Text(name)
                .font(.custom("Inter_18pt-SemiBold", size: 12))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)

            Text(count)
                .font(.custom("Inter_18pt-Regular", size: 11))
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// live queue card - this card is supposed to change its mode depending on the status of the queue xxxx
struct LiveQueueCard: View {
    var onTap: () -> Void = {}
    let steps = ["Registration", "Consultation", "Lab Tests", "Pharmacy", "Payment"]
    let currentStep = 1

    var body: some View {
        Button(action: onTap) {
        GradientCard(cornerRadius: 20) {
            VStack(spacing: 0) {
                // Top row — Live + Token
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.errorRed)
                            .frame(width: 7, height: 7)
                        Text("Live")
                            .font(.custom("Inter_18pt-Bold", size: 13))
                            .foregroundColor(.errorRed)
                    }
                    Spacer()
                    Text("BM240126-11")
                        .font(.custom("Inter_18pt-Bold", size: 14))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 10)

                // Doctor row + queue circle
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dr. Prasad Pathirana")
                            .font(.custom("Inter_18pt-Bold", size: 16))
                            .foregroundColor(.white)
                        Text("Ophthalmologist")
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.7))

                        HStack(spacing: 14) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("12 min")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("Room 89B, Floor 3")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.top, 4)
                    }

                    Spacer()

                    // Queue number circle
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 60, height: 60)
                        VStack(spacing: 0) {
                            Text("6")
                                .font(.custom("Inter_18pt-Black", size: 24))
                                .foregroundColor(.white)
                            Text("QUEUE")
                                .font(.custom("Inter_18pt-Bold", size: 7))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

 
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 16)

                // used to display the progress levels of the user and what stage of progess they are in
                HStack(spacing: 0) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        VStack(spacing: 6) {
                            ZStack {
                                if i < currentStep {
                                    Circle()
                                        .fill(Color.successGreen)
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                } else if i == currentStep {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 28, height: 28)
                                    Text("\(i + 1)")
                                        .font(.custom("Inter_18pt-Bold", size: 12))
                                        .foregroundColor(.primaryBlue)
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 28, height: 28)
                                    Text("\(i + 1)")
                                        .font(.custom("Inter_18pt-Regular", size: 12))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            Text(steps[i])
                                .font(.custom("Inter_18pt-Regular", size: 8))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .frame(width: 52)
                        }

                        if i < steps.count - 1 {
                            Rectangle()
                                .fill(i < currentStep ? Color.successGreen : Color.white.opacity(0.2))
                                .frame(height: 2)
                                .padding(.bottom, 22)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)

                // View Full Status
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Text("View Full Status")
                            .font(.custom("Inter_18pt-SemiBold", size: 12))
                            .foregroundColor(.white.opacity(0.8))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 14)
                }
            }
        }
        .buttonStyle(.plain)
        }
    }
}

// used to check the appointments and their level of appointment
struct AppointmentsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Bookings")
                .font(.custom("Inter_18pt-Bold", size: 18))
                .foregroundColor(.primaryBlue)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 4)
            AppointmentCard(
                image: "doctor_kamal",
                name: "Dr. Kamal Yugasnan",
                specialty: "cardiologist",
                bookingID: "BM240126-11",
                date: "30 / 04 / 2026",
                time: "16:00 pm"
            )
            .padding(.horizontal, 20)
            AppointmentCard(
                image: "doctor_nipun",
                name: "Dr. Nipun Perera",
                specialty: "Immunologist",
                bookingID: "BM100126-04",
                date: "01 / 05 / 2026",
                time: "18:00 pm"
            )
            .padding(.horizontal, 20)
        }
    }
}
//appoints that are static to set into since its static xxxx
struct AppointmentCard: View {
    let image: String
    let name: String
    let specialty: String
    let bookingID: String
    let date: String
    let time: String

    var body: some View {
        HStack(spacing: 14) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 54, height: 54)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.custom("Inter_18pt-Bold", size: 14))
                    .foregroundColor(.textPrimary)

                HStack(spacing: 4) {
                    Text(specialty)
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                    Text("|")
                        .foregroundColor(.textTertiary)
                    Text(bookingID)
                        .font(.custom("Inter_18pt-SemiBold", size: 12))
                        .foregroundColor(Color(hex: "F59E0B"))
                }

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)
                        Text(date)
                            .font(.custom("Inter_18pt-Regular", size: 11))
                            .foregroundColor(.textTertiary)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)
                        Text(time)
                            .font(.custom("Inter_18pt-Regular", size: 11))
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// used to give a rough summery of the users heath ect...
struct HealthSummarySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Health Summary")
                .font(.custom("Inter_18pt-Bold", size: 18))
                .foregroundColor(.primaryBlue)
                .padding(.horizontal, 20)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                // Age + Gender
                VStack(alignment: .leading, spacing: 6) {
                    Text("Age")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                    Text("25")
                        .font(.custom("Inter_18pt-ExtraBold", size: 22))
                        .foregroundColor(.textPrimary)
                    Text("Gender")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                    Text("FEMALE")
                        .font(.custom("Inter_18pt-ExtraBold", size: 16))
                        .foregroundColor(.primaryBlue)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)

                // Weight + Height
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Weight")
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text("Good")
                            .font(.custom("Inter_18pt-SemiBold", size: 10))
                            .foregroundColor(.successGreen)
                    }
                    Text("55 Kg")
                        .font(.custom("Inter_18pt-ExtraBold", size: 22))
                        .foregroundColor(.textPrimary)
                    Text("Height")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                    Text("155 cm")
                        .font(.custom("Inter_18pt-ExtraBold", size: 16))
                        .foregroundColor(.textPrimary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)

                // BMI
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("BMI")
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text("Normal")
                            .font(.custom("Inter_18pt-SemiBold", size: 10))
                            .foregroundColor(.primaryBlue)
                    }
                    Text("25 Kg/M²")
                        .font(.custom("Inter_18pt-ExtraBold", size: 20))
                        .foregroundColor(.textPrimary)
                    Text("Healthy BMI range:\n18.5 Kg/M² - 25 Kg/M²")
                        .font(.custom("Inter_18pt-Regular", size: 10))
                        .foregroundColor(.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)

                // Blood Type
                VStack(alignment: .leading, spacing: 6) {
                    Text("Blood Type")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                    Text("O +")
                        .font(.custom("Inter_18pt-ExtraBold", size: 22))
                        .foregroundColor(.textPrimary)
                    Text("The most common Blood Type, Found in roughly 35-38% of the population")
                        .font(.custom("Inter_18pt-Regular", size: 10))
                        .foregroundColor(.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
        }
    }
}

// companion mode used to change the companion levels and what the companion is suppiosed to do and what they are doing
struct CompanionSection: View {
    var onTap: () -> Void = {}
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Companion")
                .font(.custom("Inter_18pt-Bold", size: 18))
                .foregroundColor(.primaryBlue)
                .padding(.horizontal, 20)

            Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "EDE9FE"))
                        .frame(width: 42, height: 42)
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "7C3AED"))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Amal Perera")
                        .font(.custom("Inter_18pt-Bold", size: 15))
                        .foregroundColor(.textPrimary)
                    Text("Father . 5th in Queue")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textTertiary)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 20)
            }
            .buttonStyle(.plain)
        }
    }
}

// calendar
struct CalendarSection: View {
    var onTap: () -> Void = {}
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calendar")
                .font(.custom("Inter_18pt-Bold", size: 18))
                .foregroundColor(.primaryBlue)
                .padding(.horizontal, 20)

            Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "FEF3C7"))
                        .frame(width: 42, height: 42)
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "D97706"))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Dr. Prasad Pathirana")
                        .font(.custom("Inter_18pt-Bold", size: 15))
                        .foregroundColor(.textPrimary)
                    Text("Ophthalmologist . 2:30 PM")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textTertiary)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 20)
            }
            .buttonStyle(.plain)
        }
    }
}
