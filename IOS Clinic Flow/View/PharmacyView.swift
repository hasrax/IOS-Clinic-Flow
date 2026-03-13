//
//  PharmacyView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-09.
//

import SwiftUI

// MARK: - Tabs
enum PharmacyTab: String, CaseIterable {
    case current     = "Current"
    case pastOrders  = "Past Orders"
}

//Pharmacy Medication Item model
struct PharmacyMedItem: Identifiable {
    let id = UUID()
    let name: String
    let dosage: String
    let qty: Int
    let price: Int
    var isSelected: Bool = true
}

//Past Pharmacy Order model
struct PastPharmacyOrder: Identifiable {
    let id: String
    let doctor: String
    let date: String
    let itemCount: Int
    let total: Int
    let status: String   // "Collected"
}

//layout design
struct PharmacyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: PharmacyTab = .current
    @State private var showPayment = false
    @State private var showMedDetail: PharmacyMedItem? = nil
    @State private var showMedDetailNav = false
    @State private var navTab: TabItem = .home

    @State private var medications: [PharmacyMedItem] = [
        PharmacyMedItem(name: "Amoxicillin 500mg",  dosage: "3 times/day, 7 days", qty: 21, price: 620, isSelected: true),
        PharmacyMedItem(name: "Omeprazole 20mg",    dosage: "2 times/day, 7 days", qty: 21, price: 280, isSelected: false),
        PharmacyMedItem(name: "Paracetamol 500mg",  dosage: "3 times/day, 5 days", qty: 15, price: 500, isSelected: true),
    ]

    private let pastOrders: [PastPharmacyOrder] = [
        PastPharmacyOrder(id: "PH-0028", doctor: "Dr. Nimal Fernando",
                          date: "Feb 10, 2026 - 9:00 AM", itemCount: 2, total: 620, status: "Collected"),
        PastPharmacyOrder(id: "PH-0019", doctor: "Dr. Samantha Perera",
                          date: "Jan 28, 2026 - 11:00 AM", itemCount: 4, total: 1350, status: "Collected"),
    ]

    private var selectedTotal: Int {
        medications.filter(\.isSelected).reduce(0) { $0 + $1.price }
    }
    private var selectedCount: Int {
        medications.filter(\.isSelected).count
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
                    Text("Pharmacy")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Spacer().frame(width: 38)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                // Tab selector
                HStack(spacing: 0) {
                    ForEach(PharmacyTab.allCases, id: \.self) { tab in
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
                .padding(.bottom, 14)

                if selectedTab == .current {
                    currentTabContent
                } else {
                    pastOrdersContent
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear { if AppRouter.shared.pendingTab != nil { dismiss() } }
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
        .navigationDestination(isPresented: $showPayment) {
            PharmacyPaymentView(selectedTotal: selectedTotal, selectedCount: selectedCount)
        }
        .navigationDestination(isPresented: $showMedDetailNav) {
            if let med = showMedDetail {
                MedicationDetailView(medication: med)
            }
        }
    }

    // MARK: - Current Tab
    private var currentTabContent: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Token card
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient.primaryGradientDeep)
                        VStack(spacing: 8) {
                            Text("PHARMACY TOKEN")
                                .font(.custom("Inter_18pt-SemiBold", size: 11))
                                .foregroundColor(.white.opacity(0.7))
                                .tracking(1.5)
                            Text("PH-0034")
                                .font(.custom("Inter_18pt-Black", size: 32))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 22)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)

                    // Progression card
                    VStack(spacing: 12) {
                        HStack(spacing: 0) {
                            // Step 1 — done
                            stepCircle(label: "Ordering",  index: 1, state: .done)
                            stepLine(done: true)
                            // Step 2 — active
                            stepCircle(label: "Preparing", index: 2, state: .active)
                            stepLine(done: false)
                            // Step 3 — pending
                            stepCircle(label: "Ready",     index: 3, state: .pending)
                        }

                        // Estimated banner
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.warningAmber)
                            Text("Ready in ~ 15 min")
                                .font(.custom("Inter_18pt-Medium", size: 13))
                                .foregroundColor(.warningAmber)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "FEF3C7")))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 20)

                    // Medications header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prescribed Medications")
                            .font(.custom("Inter_18pt-Bold", size: 16))
                            .foregroundColor(.textPrimary)
                        Text("Dr. Samantha Perera")
                            .font(.custom("Inter_18pt-Regular", size: 13))
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Medication rows
                    VStack(spacing: 0) {
                        ForEach(Array(medications.indices), id: \.self) { i in
                            Button {
                                showMedDetail = medications[i]
                                showMedDetailNav = true
                            } label: {
                                HStack(spacing: 12) {
                                    // Checkbox
                                    Button {
                                        medications[i].isSelected.toggle()
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(medications[i].isSelected ? Color.primaryBlue : Color(hex: "D1D5DB"), lineWidth: 2)
                                                .frame(width: 22, height: 22)
                                            if medications[i].isSelected {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(Color.primaryBlue)
                                                    .frame(width: 22, height: 22)
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)

                                    // Pill icon
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.purpleTint)
                                            .frame(width: 42, height: 42)
                                        Image(systemName: "pills.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.purpleAccent)
                                    }

                                    // Name/dosage
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(medications[i].name)
                                            .font(.custom("Inter_18pt-SemiBold", size: 14))
                                            .foregroundColor(.textPrimary)
                                        Text(medications[i].dosage)
                                            .font(.custom("Inter_18pt-Regular", size: 12))
                                            .foregroundColor(.textSecondary)
                                        Text("Qty: \(medications[i].qty)")
                                            .font(.custom("Inter_18pt-Regular", size: 11))
                                            .foregroundColor(.textTertiary)
                                    }

                                    Spacer()

                                    Text("LKR \(medications[i].price)")
                                        .font(.custom("Inter_18pt-Bold", size: 14))
                                        .foregroundColor(.primaryBlue)

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.textTertiary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white)
                            }
                            .buttonStyle(.plain)

                            if i < medications.count - 1 {
                                Divider().padding(.horizontal, 16)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 140)
                }
                .padding(.top, 4)
            }

            // Bottom bar
            VStack(spacing: 0) {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Selected (\(selectedCount))")
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                        Text("LKR \(String(format: "%.2f", Double(selectedTotal)))")
                            .font(.custom("Inter_18pt-Bold", size: 16))
                            .foregroundColor(.primaryBlue)
                    }
                    Spacer()
                    Button { showPayment = true } label: {
                        Text("Pay Now")
                            .font(.custom("Inter_18pt-SemiBold", size: 15))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(selectedCount > 0
                                        ? AnyView(LinearGradient.primaryGradient)
                                        : AnyView(Color.textTertiary))
                            .cornerRadius(12)
                    }
                    .disabled(selectedCount == 0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.white)

                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
    }

    // MARK: - Past Orders Tab
    private var pastOrdersContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(pastOrders) { order in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

                        // Green left bar
                        HStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.successGreen)
                                .frame(width: 5)
                            Spacer()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(order.id)
                                    .font(.custom("Inter_18pt-Bold", size: 13))
                                    .foregroundColor(.primaryBlue)
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .bold))
                                    Text(order.status)
                                        .font(.custom("Inter_18pt-SemiBold", size: 11))
                                }
                                .foregroundColor(.successGreen)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "22C55E").opacity(0.10)))
                            }

                            Text(order.doctor)
                                .font(.custom("Inter_18pt-Bold", size: 15))
                                .foregroundColor(.textPrimary)

                            Text("\(order.date) ~ \(order.itemCount) Items")
                                .font(.custom("Inter_18pt-Regular", size: 12))
                                .foregroundColor(.textTertiary)

                            Text("LKR \(order.total)")
                                .font(.custom("Inter_18pt-Bold", size: 15))
                                .foregroundColor(.primaryBlue)

                            Button {} label: {
                                Text("View Order Details")
                                    .font(.custom("Inter_18pt-Medium", size: 13))
                                    .foregroundColor(.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 9)
                                    .background(Color.surfaceMuted)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 14)
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 20)
                }

                Spacer().frame(height: 100)
            }
            .padding(.top, 4)
        }
        // show tab bar at bottom
        .safeAreaInset(edge: .bottom) {
            BottomTabBar(selectedTab: $navTab, isNeutral: true)
        }
    }

    // MARK: - Stepper Helpers
    private enum StepState { case done, active, pending }
    
    private func stepCircle(label: String, index: Int, state: StepState) -> some View {
        VStack(spacing: 6) {
            ZStack {
                switch state {
                case .done:
                    Circle().fill(Color.successGreen).frame(width: 34, height: 34)
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                case .active:
                    Circle().stroke(Color.primaryBlueDark, lineWidth: 2).frame(width: 34, height: 34)
                    Text("\(index)")
                        .font(.custom("Inter_18pt-Bold", size: 14))
                        .foregroundColor(.primaryBlueDark)
                case .pending:
                    Circle().stroke(Color(hex: "D1D5DB"), lineWidth: 2).frame(width: 34, height: 34)
                    Text("\(index)")
                        .font(.custom("Inter_18pt-Regular", size: 14))
                        .foregroundColor(.textTertiary)
                }
            }
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 11))
                .foregroundColor(state == .pending ? .textTertiary : .textPrimary)
        }
    }

    private func stepLine(done: Bool) -> some View {
        Rectangle()
            .fill(done ? Color.successGreen : Color(hex: "D1D5DB"))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 22)
    }
}

// MARK: - Pharmacy Payment View

struct PharmacyPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedTotal: Int
    let selectedCount: Int
    @State private var isFeeSelected = true
    @State private var isCash = false
    @State private var selectedCard = 0
    @State private var showSuccess = false
    @State private var showCashCounter = false
    @State private var navigateHome = false
    @State private var showAddCard = false
    @State private var navTab: TabItem = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
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
                        // Outstanding
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(LinearGradient.primaryGradientDeep)
                            VStack(spacing: 8) {
                                Text("TOTAL OUTSTANDING")
                                    .font(.custom("Inter_18pt-SemiBold", size: 11))
                                    .foregroundColor(.white.opacity(0.75))
                                    .tracking(1.5)
                                Text("LKR \(selectedTotal)")
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

                            Button { withAnimation { isFeeSelected.toggle() } } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(isFeeSelected ? Color.primaryBlue : Color(hex: "D1D5DB"), lineWidth: 2)
                                            .frame(width: 22, height: 22)
                                        if isFeeSelected {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.primaryBlue).frame(width: 22, height: 22)
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Pharmacy Fee")
                                            .font(.custom("Inter_18pt-Medium", size: 14))
                                            .foregroundColor(.textPrimary)
                                        Text("\(selectedCount) Items")
                                            .font(.custom("Inter_18pt-Regular", size: 12))
                                            .foregroundColor(.textSecondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("LKR \(String(format: "%.2f", Double(selectedTotal)))")
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
                                        .stroke(Color.surfaceMuted, lineWidth: 1)
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
                                let cardSel = !isCash && selectedCard == 0
                                Button { isCash = false; selectedCard = 0 } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "creditcard.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(cardSel ? .primaryBlue : .textTertiary)
                                        Text("Visa ****4532")
                                            .font(.custom("Inter_18pt-Medium", size: 13))
                                            .foregroundColor(cardSel ? .textPrimary : .textTertiary)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 22)
                                    .background(Color.white).cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(cardSel ? Color.primaryBlue : Color.surfaceMuted,
                                                lineWidth: cardSel ? 2 : 1))
                                }
                                Button { isCash = true } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "banknote")
                                            .font(.system(size: 22))
                                            .foregroundColor(isCash ? Color(hex: "1B7C4E") : .textTertiary)
                                        Text("Cash")
                                            .font(.custom("Inter_18pt-Medium", size: 13))
                                            .foregroundColor(isCash ? .textPrimary : .textTertiary)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 22)
                                    .background(isCash ? Color(hex: "1B7C4E").opacity(0.07) : Color.white)
                                    .cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(isCash ? Color(hex: "1B7C4E") : Color.surfaceMuted,
                                                lineWidth: isCash ? 2 : 1))
                                }
                                Button { showAddCard = true } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 20)).foregroundColor(.textTertiary)
                                        Text("Add Card")
                                            .font(.custom("Inter_18pt-Medium", size: 12)).foregroundColor(.textTertiary)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 22)
                                    .background(Color.white).cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.surfaceMuted, lineWidth: 1))
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
                    Rectangle().fill(Color.surfaceMuted).frame(height: 1)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Selected (1)")
                                .font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(.textSecondary)
                            Text("LKR \(String(format: "%.2f", Double(selectedTotal)))")
                                .font(.custom("Inter_18pt-Bold", size: 16)).foregroundColor(.primaryBlue)
                        }
                        Spacer()
                        Button {
                            if isCash { showCashCounter = true } else { showSuccess = true }
                        } label: {
                            HStack(spacing: 8) {
                                if isCash {
                                    Image(systemName: "banknote")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                Text(isCash ? "Proceed with Cash" : "Pay Now")
                                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 26).padding(.vertical, 14)
                            .background(isFeeSelected
                                        ? (isCash ? AnyView(Color(hex: "1B7C4E")) : AnyView(LinearGradient.primaryGradient))
                                        : AnyView(Color.textTertiary))
                            .cornerRadius(12)
                        }
                        .disabled(!isFeeSelected)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 14)
                    .background(Color.white)
                }

                BottomTabBar(selectedTab: $navTab, isNeutral: true) { tab in
                    AppRouter.shared.pendingTab = tab
                    if tab == .home {
                        navigateHome = true
                    } else {
                        dismiss()
                    }
                }
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
            PharmacyPaymentSuccessView(totalPaid: selectedTotal)
        }
        .navigationDestination(isPresented: $showCashCounter) {
            CashCounterView(totalAmount: selectedTotal, doctorName: "Pharmacy", itemCount: selectedCount)
        }
        .navigationDestination(isPresented: $navigateHome) {
            HomeView(isReturningUser: true)
                .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Payment Success
struct PharmacyPaymentSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    let totalPaid: Int
    @State private var navigateHome = false
    @State private var navTab: TabItem = .home

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // ── Blue header ──────────────────────────────────────────
                        VStack(spacing: 0) {
                            // Nav row
                            HStack {
                                Button { dismiss() } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Text("Payment")
                                    .font(.custom("Inter_18pt-Bold", size: 18))
                                    .foregroundColor(.white)
                                Spacer()
                                Color.clear.frame(width: 24, height: 24)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 60)
                            .padding(.bottom, 8)

                            // Success icon
                            ZStack {
                                Circle()
                                    .fill(Color.successGreen)
                                    .frame(width: 70, height: 70)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 16)

                            Text("Successful !")
                                .font(.custom("Inter_18pt-Bold", size: 22))
                                .foregroundColor(.white)
                                .padding(.top, 16)

                            Text("Your pharmacy payment has been\npaid successfully")
                                .font(.custom("Inter_18pt-Regular", size: 14))
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                                .padding(.bottom, 60)
                        }
                        .background(
                            LinearGradient.primaryGradient
                                .ignoresSafeArea(edges: .top)
                                .clipShape(UnevenRoundedRectangle(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 28,
                                    bottomTrailingRadius: 28,
                                    topTrailingRadius: 0,
                                    style: .continuous
                                ))
                        )

                        // ── Receipt card ─────────────────────────────────────────
                        VStack(spacing: 0) {
                            // Pharmacy number
                            VStack(spacing: 4) {
                                Text("Pharmacy No")
                                    .font(.custom("Inter_18pt-Regular", size: 13))
                                    .foregroundColor(.textSecondary)
                                Text("PH-0034")
                                    .font(.custom("Inter_18pt-ExtraBold", size: 28))
                                    .foregroundColor(.textPrimary)
                            }
                            .padding(.top, 20)

                            Divider().padding(.horizontal, 20)

                            // Doctor row
                            HStack(spacing: 12) {
                                Image("doctor_kamal")
                                    .resizable().scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Dr. Samantha Perera")
                                        .font(.custom("Inter_18pt-Bold", size: 15))
                                        .foregroundColor(.textPrimary)
                                    Text("General Medicine")
                                        .font(.custom("Inter_18pt-Regular", size: 12))
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)

                            Divider().padding(.horizontal, 20)

                            // Detail rows
                            VStack(spacing: 12) {
                                detailRow(icon: "calendar",      label: "Date",     value: "February 25, 2026")
                                detailRow(icon: "clock",         label: "Time",     value: "10.00 AM")
                                detailRow(icon: "mappin",        label: "Location", value: "Pharmacy, Floor 1")
                                HStack(spacing: 10) {
                                    Image(systemName: "person")
                                        .font(.system(size: 14))
                                        .foregroundColor(.textTertiary)
                                        .frame(width: 20)
                                    Text("Patient")
                                        .font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(.textSecondary)
                                    Text("Mahel Perera")
                                        .font(.custom("Inter_18pt-Medium", size: 13))
                                        .foregroundColor(.textPrimary)
                                    Text("Spouse")
                                        .font(.custom("Inter_18pt-Medium", size: 11))
                                        .foregroundColor(.primaryBlue)
                                        .padding(.horizontal, 10).padding(.vertical, 4)
                                        .background(Color.primaryBlueTint)
                                        .cornerRadius(12)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)

                            Divider().padding(.horizontal, 20)

                            // Total paid
                            HStack {
                                Text("Total Paid")
                                    .font(.custom("Inter_18pt-Medium", size: 14))
                                    .foregroundColor(.primaryBlue)
                                Spacer()
                                Text("LKR \(formattedAmount(totalPaid))")
                                    .font(.custom("Inter_18pt-Bold", size: 16))
                                    .foregroundColor(.primaryBlue)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .padding(.top, 4)
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                        Spacer().frame(height: 120)
                    }
                }

                // Bottom button
                VStack(spacing: 12) {
                    Button { navigateHome = true } label: {
                        Text("Go to Home")
                            .font(.custom("Inter_18pt-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primaryBlueDark)
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)

                BottomTabBar(selectedTab: $navTab, isNeutral: true) { tab in
                    AppRouter.shared.pendingTab = tab
                    if tab == .home {
                        navigateHome = true
                    } else {
                        dismiss()
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; navigateHome = true }
        .navigationDestination(isPresented: $navigateHome) {
            HomeView(isReturningUser: true).navigationBarBackButtonHidden(true)
        }
    }

    private func formattedAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.textTertiary)
                .frame(width: 20)
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 13))
                .foregroundColor(.textSecondary)
            Text(value)
                .font(.custom("Inter_18pt-Medium", size: 13))
                .foregroundColor(.textPrimary)
            Spacer()
        }
    }
}

// MARK: - Success Curve Shape
// (removed — replaced with UnevenRoundedRectangle)
