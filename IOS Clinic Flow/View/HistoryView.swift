//
//  HistoryView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-09.
//
import SwiftUI


// filter tab names for the cases

enum HistoryFilter: String, CaseIterable {
    case all = "All"
    case bookings = "Bookings"
    case lab = "Lab"
    case pharmacy = "Pharmacy"
}

//categorizations
enum HistoryItemType {
    case booking, lab, pharmacy, payment
}

//shows the relevant sets to the activities
enum HistoryStatus {
    case completed, cancelled, refunded

    var label: String {
        switch self {
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .refunded: return "Refunded"
        }
    }

    var color: Color {
        switch self {
        case .completed: return .successGreen
        case .cancelled: return .errorRed
        case .refunded: return .warningAmber
        }
    }

    var background: Color {
        switch self {
        case .completed: return Color(hex: "22C55E").opacity(0.10)
        case .cancelled: return Color(hex: "EF4444").opacity(0.08)
        case .refunded: return Color(hex: "F59E0B").opacity(0.10)
        }
    }

    var icon: String {
        switch self {
        case .completed: return "checkmark"
        case .cancelled: return "xmark"
        case .refunded: return "arrow.uturn.left"
        }
    }
}

//history card data model
struct HistoryEntry: Identifiable {
    let id = UUID()
    let type: HistoryItemType    // Used to determine which card style to render
    let title: String            // Doctor name, test name, or drug name
    let reference: String        // Booking/lab/payment reference number
    let date: String             // Formatted date string e.g. "Feb 23, 2026"
    let doctor: String           // Doctor or issuer name
    let amount: Int              // Amount in LKR
    let status: HistoryStatus    // Outcome badge shown on the card
    var specialty: String? = nil // Optional specialty shown for bookings
    var time: String? = nil      // Optional time shown for booking cards
}

struct HistoryView: View {
    @ObservedObject private var router = AppRouter.shared
    //current selected tab
    @State private var selectedFilter: HistoryFilter = .all
    //navigation to visit detail card
    @State private var showVisitDetail = false

    private var tabBinding: Binding<TabItem> {
        Binding(
            get: { AppRouter.shared.activeTab },
            set: { tab in if tab != .history { AppRouter.shared.pendingTab = tab } }
        )
    }

    // MARK: Mock Data for the history view
    private let bookings: [HistoryEntry] = [
        HistoryEntry(type: .booking, title: "Dr Hasra Gunawardena", reference: "#A-0247",
                     date: "Feb 23, 2026", doctor: "Local Medicine", amount: 3220,
                     status: .completed, specialty: "Local Medicine", time: "2.30 PM"),
        HistoryEntry(type: .booking, title: "Dr Hasra Gunawardena", reference: "#A-0247",
                     date: "Feb 23, 2026", doctor: "Local Medicine", amount: 3220,
                     status: .completed, specialty: "Local Medicine", time: "2.30 PM"),
        HistoryEntry(type: .booking, title: "Dr Hasra Gunawardena", reference: "#A-0247",
                     date: "Feb 23, 2026", doctor: "Local Medicine", amount: 3220,
                     status: .completed, specialty: "Local Medicine", time: "2.30 PM"),
    ]

    private let labItems: [HistoryEntry] = [
        HistoryEntry(type: .lab, title: "Urinalysis", reference: "Lab - 0088 - Feb 20, 2026",
                     date: "Feb 20, 2026", doctor: "Dr Kithnuka Gunawardena", amount: 500, status: .completed),
        HistoryEntry(type: .lab, title: "Urinalysis", reference: "Lab - 0088 - Feb 20, 2026",
                     date: "Feb 20, 2026", doctor: "Dr Kithnuka Gunawardena", amount: 500, status: .cancelled),
        HistoryEntry(type: .lab, title: "Urinalysis", reference: "Lab - 0088 - Feb 20, 2026",
                     date: "Feb 20, 2026", doctor: "Dr Kithnuka Gunawardena", amount: 500, status: .completed),
    ]

    private let pharmacyItems: [HistoryEntry] = [
        HistoryEntry(type: .pharmacy, title: "Balsalazide", reference: "PH - 0088 - Feb 20, 2026",
                     date: "Feb 20, 2026", doctor: "Dr Ashen Gunawardena", amount: 850, status: .cancelled),
        HistoryEntry(type: .pharmacy, title: "Balsalazide", reference: "PH - 0088 - Feb 20, 2026",
                     date: "Feb 20, 2026", doctor: "Dr Ashen Gunawardena", amount: 850, status: .completed),
        HistoryEntry(type: .pharmacy, title: "Balsalazide", reference: "PH - 0088 - Feb 20, 2026",
                     date: "Feb 20, 2026", doctor: "Dr Ashen Gunawardena", amount: 850, status: .cancelled),
    ]

    private let paymentItems: [HistoryEntry] = [
        HistoryEntry(type: .payment, title: "Visit - Dr Yasith Vidusara (Cancelled)",
                     reference: "PAY - 0088 - Feb 20, 2026",
                     date: "Feb 20, 2026", doctor: "Visa *******435", amount: 850, status: .refunded),
        HistoryEntry(type: .payment, title: "Visit - Dr Yasith Vidusara (Cancelled)",
                     reference: "PAY - 0088 - Feb 20, 2026",
                     date: "Feb 20, 2026", doctor: "Visa *******435", amount: 850, status: .refunded),
        HistoryEntry(type: .payment, title: "Visit - Dr Yasith Vidusara",
                     reference: "PAY - 0088 - Feb 20, 2026",
                     date: "Feb 20, 2026", doctor: "Visa *******435", amount: 850, status: .completed),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation title bar
                Text("History")
                    .font(.custom("Inter_18pt-Bold", size: 18))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appBackground)

                if router.isNewUser {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 52))
                            .foregroundColor(Color(hex: "D8DCE6"))
                        Text("No history yet")
                            .font(.custom("Inter_18pt-Bold", size: 18))
                            .foregroundColor(.textPrimary)
                        Text("Your visits, lab tests and payments\nwill appear here once you get started")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            summaryCard.padding(.horizontal, 16)
                            filterTabs.padding(.horizontal, 16)
                            contentList.padding(.horizontal, 16)
                            Spacer().frame(height: 100)
                        }
                        .padding(.top, 12)
                    }
                }

                BottomTabBar(selectedTab: tabBinding)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showVisitDetail) {
            VisitDetailView()
        }
    }

    // MARK: - top blue summary Card
    private var summaryCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient.primaryGradientDeep)

            VStack(spacing: 14) {
                Text("TOTAL SPENT")
                    .font(.custom("Inter_18pt-SemiBold", size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1.5)

                Text("LKR 9,340")
                    .font(.custom("Inter_18pt-Black", size: 36))
                    .foregroundColor(.white)

                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 1)
                    .padding(.horizontal, 8)

                HStack(spacing: 0) {
                    hStatItem(value: "3", label: "VISITS", color: .white)
                    hDivider
                    hStatItem(value: "30", label: "LAB TEST", color: .white)
                    hDivider
                    hStatItem(value: "25", label: "PHARMACY", color: .white)
                    hDivider
                    hStatItem(value: "1.9K", label: "REFUNDED", color: Color(hex: "F59E0B"))
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
        }
    }

    private func hStatItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Inter_18pt-Bold", size: 18))
                .foregroundColor(color)
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 10))
                .foregroundColor(.white.opacity(0.6))
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private var hDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.25))
            .frame(width: 1, height: 36)
    }

    // MARK: - Filter Tabs withe the design
    private var filterTabs: some View {
        HStack(spacing: 8) {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = filter }
                } label: {
                    Text(filter.rawValue)
                        .font(.custom("Inter_18pt-SemiBold", size: 13))
                        .foregroundColor(selectedFilter == filter ? .white : .textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedFilter == filter
                                      ? Color.primaryBlueDark
                                      : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedFilter == filter
                                        ? Color.clear
                                        : Color.black.opacity(0.09), lineWidth: 1)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Contents for the tab views
    @ViewBuilder
    private var contentList: some View {
        switch selectedFilter {
        case .all:   allContent
        case .bookings:
            sectionBlock("All") {
                ForEach(bookings) { item in
                    BookingHistoryCard(item: item, onViewDetails: { showVisitDetail = true })
                }
            }
        case .lab:
            sectionBlock("All") {
                ForEach(labItems) { item in IconHistoryCard(item: item) }
            }
        case .pharmacy:
            sectionBlock("All") {
                ForEach(pharmacyItems) { item in IconHistoryCard(item: item) }
            }
        }
    }

    private var allContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionBlock("All") {
                ForEach(bookings) { item in
                    BookingHistoryCard(item: item, onViewDetails: { showVisitDetail = true })
                }
            }
            sectionBlock("Laboratory") {
                ForEach(labItems) { item in IconHistoryCard(item: item) }
            }
            sectionBlock("Pharmacy") {
                ForEach(pharmacyItems) { item in IconHistoryCard(item: item) }
            }
            sectionBlock("Payments") {
                ForEach(paymentItems) { item in IconHistoryCard(item: item) }
            }
        }
    }

    private func sectionBlock<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("Inter_18pt-SemiBold", size: 14))
                .foregroundColor(.textSecondary)
            content()
        }
    }
}

// MARK: - Booking History Card
//the card that holds all the info with accent bars and stauses
struct BookingHistoryCard: View {
    let item: HistoryEntry
    let onViewDetails: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

            // Green accent left border
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.successGreen)
                    .frame(width: 4)
                    .padding(.vertical, 0)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 8) {
                // Token/Status
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                        Text(item.reference)
                            .font(.custom("Inter_18pt-SemiBold", size: 12))
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                    HistoryStatusBadge(status: item.status)
                }

                // Doctor Name
                Text(item.title)
                    .font(.custom("Inter_18pt-Bold", size: 15))
                    .foregroundColor(.textPrimary)

                // Specialty
                if let specialty = item.specialty {
                    Text(specialty)
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.textSecondary)
                }

                // Date/Time
                if let time = item.time {
                    Text("\(item.date) - \(time)")
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textTertiary)
                }

                // Price/view Details
                HStack {
                    Text("LKR \(item.amount.formatted())")
                        .font(.custom("Inter_18pt-Bold", size: 15))
                        .foregroundColor(.primaryBlue)
                    Spacer()
                    Button(action: onViewDetails) {
                        HStack(spacing: 3) {
                            Text("View Details")
                                .font(.custom("Inter_18pt-Medium", size: 12))
                                .foregroundColor(.textSecondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
            .padding(.leading, 18)
            .padding(.trailing, 14)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - general History Card (Lab / Pharmacy / Payment)

struct IconHistoryCard: View {
    let item: HistoryEntry
    
    private var iconName: String {
        switch item.type {
        case .lab:      return "flask.fill"
        case .pharmacy: return "pill.fill"
        case .payment:  return "creditcard.fill"
        default:        return "doc.fill"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 50, height: 50)
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Infomation properties with text fonts
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.custom("Inter_18pt-Bold", size: 14))
                    .foregroundColor(.textPrimary)
                Text(item.reference)
                    .font(.custom("Inter_18pt-Regular", size: 11))
                    .foregroundColor(.textTertiary)
                Text(item.doctor)
                    .font(.custom("Inter_18pt-Regular", size: 11))
                    .foregroundColor(.textTertiary)
                Text("LKR \(item.amount.formatted())")
                    .font(.custom("Inter_18pt-Bold", size: 14))
                    .foregroundColor(.primaryBlue)
            }

            Spacer()

            // Status badge aligned in the top
            VStack {
                HistoryStatusBadge(status: item.status)
                Spacer()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .frame(maxWidth: .infinity)
    }
}

// MARK: - History Status Badge
//this is reusable by just passing its values - design
struct HistoryStatusBadge: View {
    let status: HistoryStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: 9, weight: .bold))
            Text(status.label)
                .font(.custom("Inter_18pt-SemiBold", size: 11))
        }
        .foregroundColor(status.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(status.background)
        )
    }
}
