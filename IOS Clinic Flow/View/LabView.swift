import SwiftUI

// MARK: - Tab names
enum LabTabFilter: String, CaseIterable {
    case upcoming  = "Upcoming"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Test Statuses
enum LabTestStatus {
    case processing, waiting, completed, cancelled

    //to show the status
    var label: String {
        switch self {
        case .processing: return "Processing"
        case .waiting:    return "Waiting"
        case .completed:  return "Completed"
        case .cancelled:  return "Cancelled"
        }
    }

    //to show the text color
    var color: Color {
        switch self {
        case .processing: return Color(hex: "D97706")
        case .waiting:    return Color.textSecondary
        case .completed:  return Color(hex: "22C55E")
        case .cancelled:  return Color(hex: "EF4444")
        }
    }

    //to show the background tint
    var background: Color {
        switch self {
        case .processing: return Color(hex: "FEF3C7")
        case .waiting:    return Color.surfaceMuted
        case .completed:  return Color(hex: "22C55E").opacity(0.10)
        case .cancelled:  return Color(hex: "EF4444").opacity(0.08)
        }
    }

    //the colour that sued for the vertical line in crds
    var accentColor: Color {
        switch self {
        case .processing: return Color(hex: "F59E0B")
        case .waiting:    return Color.textTertiary
        case .completed:  return Color(hex: "22C55E")
        case .cancelled:  return Color(hex: "EF4444")
        }
    }
}

// MARK: - Lab Test Item Model part
struct LabTestItem: Identifiable {
    let id = UUID()
    let labId: String
    let testName: String
    let nurse: String?
    let location: String
    let estimated: String
    let status: LabTestStatus
    let date: String?
    let doctor: String?
}

// MARK: - lab view starts from here
struct LabView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var router = AppRouter.shared
    @State private var selectedTab: LabTabFilter = .upcoming
    @State private var showPayment = false
    @State private var showReport = false
    @State private var selectedReportItem: LabTestItem? = nil
    @State private var navTab: TabItem = .home

    private let upcomingItems: [LabTestItem] = [
        LabTestItem(labId: "LAB-0089", testName: "Complete Blood Count (CBC)",
                    nurse: "Nurse Dilani", location: "Lab Room 3, Floor 1",
                    estimated: "Estimated: ~20 min", status: .processing,
                    date: nil, doctor: nil),
        LabTestItem(labId: "LAB-0090", testName: "Lipid Profile",
                    nurse: "Pending", location: "Lab Room 3, Floor 1",
                    estimated: "Estimated: After CBC", status: .waiting,
                    date: nil, doctor: nil),
    ]

    private let completedItems: [LabTestItem] = [
        LabTestItem(labId: "LAB-0088", testName: "Urinalysis",
                    nurse: nil, location: "Lab Room 1, Floor 1",
                    estimated: "", status: .completed,
                    date: "Feb 15, 2026  9:00 AM", doctor: "Dr. Nimal Fernando"),
        LabTestItem(labId: "LAB-0085", testName: "Blood Glucose (Fasting)",
                    nurse: nil, location: "Lab Room 2, Floor 1",
                    estimated: "", status: .completed,
                    date: "Feb 20, 2026  9:00 AM", doctor: "Dr. Samantha Perera"),
    ]

    private let cancelledItems: [LabTestItem] = [
        LabTestItem(labId: "LAB-0080", testName: "Complete Blood Count (CBC)",
                    nurse: "Nurse Imani", location: "Lab Room 2, Floor 1",
                    estimated: "", status: .cancelled,
                    date: nil, doctor: nil),
    ]

    //returns data for the selected tab
    private var currentItems: [LabTestItem] {
        switch selectedTab {
        case .upcoming:  return upcomingItems
        case .completed: return completedItems
        case .cancelled: return cancelledItems
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    Spacer()
                    Text("Laboratory")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Spacer().frame(width: 38)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                if router.isNewUser {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "cross.vial.fill")
                            .font(.system(size: 52))
                            .foregroundColor(Color(hex: "D8DCE6"))
                        Text("No lab records yet")
                            .font(.custom("Inter_18pt-Bold", size: 18))
                            .foregroundColor(.textPrimary)
                        Text("Your lab results will appear here\nafter your first visit")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    HStack(spacing: 0) {
                        ForEach(LabTabFilter.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                            } label: {
                                Text(tab.rawValue)
                                    .font(.custom(selectedTab == tab ? "Inter_18pt-Bold" : "Inter_18pt-Regular", size: 14))
                                    .foregroundColor(selectedTab == tab ? .white : .textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 11)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .fill(selectedTab == tab ? Color.primaryBlueDark : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(currentItems) { item in
                                LabTestCard(
                                    item: item,
                                    onViewReport: {
                                        selectedReportItem = item
                                        showReport = true
                                    }
                                )
                                .padding(.horizontal, 20)
                            }

                            if selectedTab == .upcoming {
                                Button { showPayment = true } label: {
                                    Text("Pay Lab Fee")
                                        .font(.custom("Inter_18pt-Bold", size: 16))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 17)
                                        .background(LinearGradient.primaryGradient)
                                        .cornerRadius(14)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            }

                            Spacer().frame(height: 100)
                        }
                        .padding(.top, 4)
                    }
                }

                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear { if AppRouter.shared.pendingTab != nil { dismiss() } }
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
        .navigationDestination(isPresented: $showPayment) {
            LabPaymentView()
        }
        .navigationDestination(isPresented: $showReport) {
            LabReportDetailView()
        }
    }
}

// MARK: - Lab Test Card
//design
struct LabTestCard: View {
    let item: LabTestItem
    var onViewReport: (() -> Void)? = nil //onViewReport is for to load details

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

            // Left accent bar to show status
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(item.status.accentColor)
                    .frame(width: 5)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 8) {
                // ID plus status
                HStack {
                    Text(item.labId)
                        .font(.custom("Inter_18pt-Bold", size: 13))
                        .foregroundColor(.primaryBlue)
                    Spacer()
                    Text(item.status.label)
                        .font(.custom("Inter_18pt-SemiBold", size: 11))
                        .foregroundColor(item.status.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(item.status.background)
                        )
                }

       
                Text(item.testName)
                    .font(.custom("Inter_18pt-Bold", size: 15))
                    .foregroundColor(.textPrimary)

                // Test Details
                if let nurse = item.nurse {
                    labInfoRow(icon: "person.fill", text: nurse)
                }
                if let doctor = item.doctor {
                    labInfoRow(icon: "person.fill", text: doctor)
                }
                if !item.location.isEmpty {
                    labInfoRow(icon: "mappin.fill", text: item.location)
                }
                if let date = item.date {
                    labInfoRow(icon: "clock.fill", text: date)
                }
                if !item.estimated.isEmpty {
                    labInfoRow(icon: "timer", text: item.estimated)
                }

                // Action buttons - completed
                if item.status == .completed, let onView = onViewReport {
                    HStack(spacing: 10) {
                        Button {} label: {
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.down.to.line")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("PDF")
                                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                            }
                            .foregroundColor(.primaryBlue)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primaryBlue, lineWidth: 1.5)
                            )
                        }

                        Button(action: onView) {
                            HStack(spacing: 5) {
                                Image(systemName: "eye")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("View Report")
                                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .background(LinearGradient.primaryGradient)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 14)
            .padding(.vertical, 14)
        }
    }
    //helper details - location, nurse and stuff
    private func labInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.textTertiary)
                .frame(width: 14)
            Text(text)
                .font(.custom("Inter_18pt-Regular", size: 12))
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Lab Payment
struct LabPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLabFeeSelected = true //to see if the lab fee checkbox has selected or not 
    @State private var selectedCard = 0 // 0 = current card, 1 = new card
    @State private var showSuccess = false
    @State private var showAddCard = false
    @State private var navTab: TabItem = .home

    private let labFeeAmount = 1800

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    Spacer()
                    Text("Payments")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Spacer().frame(width: 38)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Outstanding amount card
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(LinearGradient.primaryGradientDeep)
                            VStack(spacing: 8) {
                                Text("TOTAL OUTSTANDING")
                                    .font(.custom("Inter_18pt-SemiBold", size: 11))
                                    .foregroundColor(.white.opacity(0.75))
                                    .tracking(1.5)
                                Text("LKR 1,800")
                                    .font(.custom("Inter_18pt-Black", size: 34))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 20)

                        // Pending payments
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pending Payments")
                                .font(.custom("Inter_18pt-SemiBold", size: 15))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)

                            Button {
                                withAnimation { isLabFeeSelected.toggle() }
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(isLabFeeSelected ? Color.primaryBlue : Color(hex: "D1D5DB"), lineWidth: 2)
                                            .frame(width: 22, height: 22)
                                        if isLabFeeSelected {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.primaryBlue)
                                                .frame(width: 22, height: 22)
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Laboratory Fee")
                                            .font(.custom("Inter_18pt-Medium", size: 14))
                                            .foregroundColor(.textPrimary)
                                        Text("Complete Blood Count (CBC)")
                                            .font(.custom("Inter_18pt-Regular", size: 12))
                                            .foregroundColor(.textSecondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("LKR 1800.00")
                                            .font(.custom("Inter_18pt-Bold", size: 14))
                                            .foregroundColor(.primaryBlue)
                                        Text("Due : Today")
                                            .font(.custom("Inter_18pt-Regular", size: 11))
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(isLabFeeSelected ? Color.primaryBlue : Color.surfaceMuted,
                                                lineWidth: isLabFeeSelected ? 2 : 1)
                                )
                            }
                            .padding(.horizontal, 20)
                        }

                        // Payment method
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Payment Method")
                                .font(.custom("Inter_18pt-SemiBold", size: 15))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)

                            HStack(spacing: 12) {
                                // Visa card
                                Button { selectedCard = 0 } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "creditcard.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.textPrimary)
                                        Text("Visa ****4532")
                                            .font(.custom("Inter_18pt-Medium", size: 13))
                                            .foregroundColor(.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 22)
                                    .background(Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(selectedCard == 0 ? Color.primaryBlue : Color.surfaceMuted,
                                                    lineWidth: selectedCard == 0 ? 2 : 1)
                                    )
                                }
                                // Add card
                                Button { showAddCard = true } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 22))
                                            .foregroundColor(.textTertiary)
                                        Text("Add Card")
                                            .font(.custom("Inter_18pt-Medium", size: 13))
                                            .foregroundColor(.textTertiary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 22)
                                    .background(Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(selectedCard == 1 ? Color.primaryBlue : Color.surfaceMuted,
                                                    lineWidth: selectedCard == 1 ? 2 : 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 130)
                    }
                    .padding(.top, 4)
                }

                // Bottom bar
                VStack(spacing: 0) {
                    Divider()
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Selected (1)")
                                .font(.custom("Inter_18pt-Regular", size: 12))
                                .foregroundColor(.textSecondary)
                            Text("LKR 1800.00")
                                .font(.custom("Inter_18pt-Bold", size: 16))
                                .foregroundColor(.primaryBlue)
                        }
                        Spacer()
                        Button { showSuccess = true } label: {
                            Text("Pay Now")
                                .font(.custom("Inter_18pt-SemiBold", size: 15))
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(isLabFeeSelected
                                            ? AnyView(LinearGradient.primaryGradient)
                                            : AnyView(Color.textTertiary))
                                .cornerRadius(12)
                        }
                        .disabled(!isLabFeeSelected)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.white)
                }

                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
        .navigationDestination(isPresented: $showAddCard) {
            AddCardView { _ in showAddCard = false }
        }
        .navigationDestination(isPresented: $showSuccess) {
            LabPaymentSuccessView()
        }
    }
}

// MARK: - Lab Payment Success
struct LabPaymentSuccessView: View {
    @State private var navigateHome = false //triggers navigation back to homeview
    @State private var navTab: TabItem = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            // Blue curved header
            VStack(spacing: 0) {
                ZStack {
                    LabSuccessCurveShape()
                        .fill(LinearGradient.primaryGradientDeep)
                        .frame(height: 320)

                    VStack(spacing: 14) {
                        Spacer().frame(height: 40)
                        ZStack {
                            Circle()
                                .fill(Color.successGreen)
                                .frame(width: 64, height: 64)
                            Image(systemName: "checkmark")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("Successful !")
                            .font(.custom("Inter_18pt-ExtraBold", size: 26))
                            .foregroundColor(.white)
                        Text("Your lab payment has been paid\nsuccessfully")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                }
                Spacer()
            }

            // Receipt card + button
            VStack(spacing: 0) {
                Spacer().frame(height: 230)

                VStack(spacing: 16) {
                    // Receipt card
                    VStack(spacing: 0) {
                        VStack(spacing: 6) {
                            Text("LAB NO")
                                .font(.custom("Inter_18pt-Regular", size: 11))
                                .foregroundColor(.textTertiary)
                                .tracking(1)
                            Text("LAB-0089")
                                .font(.custom("Inter_18pt-Black", size: 28))
                                .foregroundColor(.primaryBlue)
                        }
                        .padding(.vertical, 18)

                        Divider().padding(.horizontal, 16)

                        // Doctor row
                        HStack(spacing: 12) {
                            Image("doctor_kamal")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 46, height: 46)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.borderMedium, lineWidth: 1))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Dr. Anil Ranasinghe")
                                    .font(.custom("Inter_18pt-Bold", size: 15))
                                    .foregroundColor(.textPrimary)
                                Text("Genral Medicine")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)

                        Divider().padding(.horizontal, 16)

                        // Detail rows
                        VStack(spacing: 12) {
                            receiptRow(icon: "calendar", label: "Date", value: "February 25, 2026")
                            receiptRow(icon: "clock", label: "Time", value: "10.00 AM")
                            receiptRow(icon: "mappin.circle", label: "Location", value: "Lab Room 3, Floor 1")
                            HStack(spacing: 10) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textSecondary)
                                    .frame(width: 18)
                                Text("Patient")
                                    .font(.custom("Inter_18pt-Regular", size: 13))
                                    .foregroundColor(.textSecondary)
                                Spacer()
                                HStack(spacing: 6) {
                                    Text("Spouse")
                                        .font(.custom("Inter_18pt-Medium", size: 11))
                                        .foregroundColor(.primaryBlue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(Color.primaryBlueTint))
                                    Text("Mahel Perera")
                                        .font(.custom("Inter_18pt-SemiBold", size: 13))
                                        .foregroundColor(.textPrimary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)

                        Divider().padding(.horizontal, 16)

                        HStack {
                            Text("Total Paid")
                                .font(.custom("Inter_18pt-Regular", size: 13))
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("LKR 1,800")
                                .font(.custom("Inter_18pt-Black", size: 18))
                                .foregroundColor(.primaryBlue)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)

                    // Go Home button
                    Button { navigateHome = true } label: {
                        Text("Go Home")
                            .font(.custom("Inter_18pt-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(LinearGradient.primaryGradient)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 100)
                }
            }

            BottomTabBar(selectedTab: $navTab, isNeutral: true)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; navigateHome = true }
        .navigationDestination(isPresented: $navigateHome) {
            HomeView(isReturningUser: true).navigationBarBackButtonHidden(true)
        }
    }

    private func receiptRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
                .frame(width: 18)
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 13))
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.custom("Inter_18pt-SemiBold", size: 13))
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Lab Success Curve Shape
private struct LabSuccessCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 60))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY - 60),
            control: CGPoint(x: rect.midX, y: rect.maxY + 44)
        )
        path.closeSubpath()
        return path
    }
}


