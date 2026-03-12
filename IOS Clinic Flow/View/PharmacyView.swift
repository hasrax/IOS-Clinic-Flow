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
    @State private var selectedCard = 0
    @State private var showSuccess = false
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
                                        .stroke(isFeeSelected ? Color.primaryBlue : Color.surfaceMuted,
                                                lineWidth: isFeeSelected ? 2 : 1)
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
                                Button { selectedCard = 0 } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "creditcard.fill")
                                            .font(.system(size: 22)).foregroundColor(.textPrimary)
                                        Text("Visa ****4532")
                                            .font(.custom("Inter_18pt-Medium", size: 13)).foregroundColor(.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 22)
                                    .background(Color.white).cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedCard == 0 ? Color.primaryBlue : Color.surfaceMuted,
                                                lineWidth: selectedCard == 0 ? 2 : 1))
                                }
                                Button { showAddCard = true } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 22)).foregroundColor(.textTertiary)
                                        Text("Add Card")
                                            .font(.custom("Inter_18pt-Medium", size: 13)).foregroundColor(.textTertiary)
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
                    Divider()
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Selected (1)")
                                .font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(.textSecondary)
                            Text("LKR \(String(format: "%.2f", Double(selectedTotal)))")
                                .font(.custom("Inter_18pt-Bold", size: 16)).foregroundColor(.primaryBlue)
                        }
                        Spacer()
                        Button { showSuccess = true } label: {
                            Text("Pay Now")
                                .font(.custom("Inter_18pt-SemiBold", size: 15)).foregroundColor(.white)
                                .padding(.horizontal, 32).padding(.vertical, 14)
                                .background(isFeeSelected
                                            ? AnyView(LinearGradient.primaryGradient)
                                            : AnyView(Color.textTertiary))
                                .cornerRadius(12)
                        }
                        .disabled(!isFeeSelected)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 14)
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
            PharmacyPaymentSuccessView(totalPaid: selectedTotal)
        }
    }
}

// MARK: - Payment Success
struct PharmacyPaymentSuccessView: View {
    let totalPaid: Int          // Final amount paid in LKR
    @State private var navigateHome = false  // Triggers navigation back to HomeView
    @State private var navTab: TabItem = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            // Blue curved header
            VStack(spacing: 0) {
                ZStack {
                    PharmacySuccessCurve()
                        .fill(LinearGradient.primaryGradientDeep)
                        .frame(height: 320)

                    VStack(spacing: 14) {
                        Spacer().frame(height: 40)
                        ZStack {
                            Circle().fill(Color.successGreen).frame(width: 64, height: 64)
                            Image(systemName: "checkmark")
                                .font(.system(size: 26, weight: .bold)).foregroundColor(.white)
                        }
                        Text("Successful !")
                            .font(.custom("Inter_18pt-ExtraBold", size: 26)).foregroundColor(.white)
                        Text("Your pharmacy payment has been paid\nsuccessfully")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                }
                Spacer()
            }

            // Card/button
            VStack(spacing: 0) {
                Spacer().frame(height: 230)
                VStack(spacing: 16) {
                    VStack(spacing: 0) {
                        VStack(spacing: 6) {
                            Text("PHARMACY NO")
                                .font(.custom("Inter_18pt-Regular", size: 11)).foregroundColor(.textTertiary).tracking(1)
                            Text("PH-0034")
                                .font(.custom("Inter_18pt-Black", size: 28)).foregroundColor(.primaryBlue)
                        }
                        .padding(.vertical, 18)

                        Divider().padding(.horizontal, 16)

                        HStack(spacing: 12) {
                            Image("doctor_kamal")
                                .resizable().scaledToFill()
                                .frame(width: 46, height: 46)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.borderMedium, lineWidth: 1))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Dr. Samantha Perera")
                                    .font(.custom("Inter_18pt-Bold", size: 15)).foregroundColor(.textPrimary)
                                Text("Genral Medicine")
                                    .font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20).padding(.vertical, 14)

                        Divider().padding(.horizontal, 16)

                        VStack(spacing: 12) {
                            phRow(icon: "calendar",      label: "Date",     value: "February 25, 2026")
                            phRow(icon: "clock",         label: "Time",     value: "10.00 AM")
                            phRow(icon: "mappin.circle", label: "Location", value: "Pharmacy, Floor 1")
                            HStack(spacing: 10) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 13)).foregroundColor(.textSecondary).frame(width: 18)
                                Text("Patient").font(.custom("Inter_18pt-Regular", size: 13)).foregroundColor(.textSecondary)
                                Spacer()
                                HStack(spacing: 6) {
                                    Text("Spouse")
                                        .font(.custom("Inter_18pt-Medium", size: 11)).foregroundColor(.primaryBlue)
                                        .padding(.horizontal, 8).padding(.vertical, 3)
                                        .background(Capsule().fill(Color.primaryBlueTint))
                                    Text("Mahel Perera")
                                        .font(.custom("Inter_18pt-SemiBold", size: 13)).foregroundColor(.textPrimary)
                                }
                            }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 14)

                        Divider().padding(.horizontal, 16)

                        HStack {
                            Text("Total Paid")
                                .font(.custom("Inter_18pt-Regular", size: 13)).foregroundColor(.textSecondary)
                            Spacer()
                            Text("LKR \(totalPaid)")
                                .font(.custom("Inter_18pt-Black", size: 18)).foregroundColor(.primaryBlue)
                        }
                        .padding(.horizontal, 20).padding(.vertical, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)

                    Button { navigateHome = true } label: {
                        Text("Go Home")
                            .font(.custom("Inter_18pt-Bold", size: 16)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 17)
                            .background(LinearGradient.primaryGradient).cornerRadius(14)
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

    private func phRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 13)).foregroundColor(.textSecondary).frame(width: 18)
            Text(label).font(.custom("Inter_18pt-Regular", size: 13)).foregroundColor(.textSecondary)
            Spacer()
            Text(value).font(.custom("Inter_18pt-SemiBold", size: 13)).foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Success Curve Shape
private struct PharmacySuccessCurve: Shape {
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
