//
//  PaymentView.swift
//  IOS Clinic Flow
//
//  Created by Lakindu Siriwardena on 2026-03-10.
//


import SwiftUI

// MARK: - Payment mode selection
private enum PaymentMode: Equatable {
    case card(index: Int)
    case cash
}

// MARK: - since we are allowing users to do pending payments as well throught this we can save appropriate data for tht
private struct PendingPayItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let amount: Int
    var isSelected: Bool
}

struct PaymentView: View {
    @Environment(\.dismiss) private var dismiss
    let doctor: Doctor
    let selectedDate: Date
    let selectedTimeSlot: TimeSlot?
    let totalAmount: Int
//the docs deets will be passed over from the other screen
    @State private var showPaymentSuccess = false
    //navigation to the payment success page
    @State private var showCashCounter = false
    //navigation to cash counter instructions page
    @State private var navigateHome = false
    //direct navigation to home from bottom tab bar
    @State private var showAddCard = false
    //nav to the add card page
    @State private var navTab: TabItem = .home
    @State private var paymentMode: PaymentMode = .card(index: 0)
    //tracks selected payment method (card or cash)
    @State private var savedCards: [SavedCard] = []

    @State private var items: [PendingPayItem]

    let isFromBooking: Bool

    init(doctor: Doctor, selectedDate: Date, selectedTimeSlot: TimeSlot?, totalAmount: Int, isFromBooking: Bool = false) {
        self.doctor = doctor
        self.selectedDate = selectedDate
        self.selectedTimeSlot = selectedTimeSlot
        self.totalAmount = totalAmount
        self.isFromBooking = isFromBooking
        if isFromBooking {
            _items = State(initialValue: [
                PendingPayItem(id: "consultation", title: "Consultation Fee",
                               subtitle: doctor.name, amount: totalAmount, isSelected: true),
                PendingPayItem(id: "registration", title: "Registration Fee",
                               subtitle: "First Visit", amount: 200, isSelected: true),
            ])
        } else {
            _items = State(initialValue: [
                PendingPayItem(id: "consultation", title: "Consultation Fee",
                               subtitle: doctor.name, amount: totalAmount, isSelected: true),
                PendingPayItem(id: "registration", title: "Registration Fee",
                               subtitle: "First Visit",          amount: 200,         isSelected: true),
                PendingPayItem(id: "lab", title: "Laboratory Fee",
                               subtitle: "CBC Blood Test",        amount: 1800,        isSelected: false),
                PendingPayItem(id: "pharmacy", title: "Pharmacy",
                               subtitle: "Prescribed Medications", amount: 1200,       isSelected: false),
            ])
        }
    }
//initializing the states of the variables
    private var selectedTotal: Int { items.filter(\.isSelected).reduce(0) { $0 + $1.amount } }
    private var selectedCount: Int { items.filter(\.isSelected).count }
//calculation of all selected items
    private func rowAmount(_ amount: Int) -> String {
        String(format: "%.2f", Double(amount))
    }
//adding decimals
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()
//outstanding card design and its apprtopriate components
            VStack(spacing: 0) {
                // Custom nav bar
                HStack {
                    if !isFromBooking {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primaryBlue)
                        }
                    } else {
                        Color.clear.frame(width: 24, height: 24)
                    }
                    Spacer()
                    Text("Pay")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                    
                        // summary card — gradient
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient.primaryGradientDeep)
                            VStack(spacing: 8) {
                                Text("TOTAL OUTSTANDING")
                                    .font(.custom("Inter_18pt-SemiBold", size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                    .tracking(1.5)
                                Text("LKR \(formattedAmount(selectedTotal))")
                                    .font(.custom("Inter_18pt-Black", size: 34))
                                    .foregroundColor(.white)
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(width: 5, height: 5)
                                    Text("\(selectedCount) item\(selectedCount == 1 ? "" : "s") selected")
                                        .font(.custom("Inter_18pt-Regular", size: 12))
                                        .foregroundColor(.white.opacity(0.75))
                                }
                            }
                            .padding(.vertical, 28)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // pending payent card and all
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pending Payments")
                                .font(.custom("Inter_18pt-SemiBold", size: 16))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)

                            ForEach(items.indices, id: \.self) { i in
                                payRow(index: i)
                                    .padding(.horizontal, 20)
                            }
                        }

                        // payment method selection part
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Payment Method")
                                .font(.custom("Inter_18pt-SemiBold", size: 16))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)

                            HStack(spacing: 12) {
                                // Default Visa card
                                let cardSelected = paymentMode == .card(index: 0)
                                Button { paymentMode = .card(index: 0) } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "creditcard.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(cardSelected ? .primaryBlue : .textTertiary)
                                        Text("Visa ****4532")
                                            .font(.custom("Inter_18pt-Medium", size: 13))
                                            .foregroundColor(cardSelected ? .textPrimary : .textTertiary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 22)
                                    .background(Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(cardSelected ? Color.primaryBlue : Color.surfaceMuted,
                                                    lineWidth: cardSelected ? 2 : 1)
                                    )
                                }

                                // Cash
                                let cashSelected = paymentMode == .cash
                                Button { paymentMode = .cash } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "banknote")
                                            .font(.system(size: 22))
                                            .foregroundColor(cashSelected ? Color(hex: "1B7C4E") : .textTertiary)
                                        Text("Cash")
                                            .font(.custom("Inter_18pt-Medium", size: 13))
                                            .foregroundColor(cashSelected ? .textPrimary : .textTertiary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 22)
                                    .background(cashSelected ? Color(hex: "1B7C4E").opacity(0.07) : Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(cashSelected ? Color(hex: "1B7C4E") : Color.surfaceMuted,
                                                    lineWidth: cashSelected ? 2 : 1)
                                    )
                                }

                                // Add card
                                Button { showAddCard = true } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 20))
                                            .foregroundColor(.textTertiary)
                                        Text("Add Card")
                                            .font(.custom("Inter_18pt-Medium", size: 12))
                                            .foregroundColor(.textTertiary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 22)
                                    .background(Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.surfaceMuted, lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 140)
                    }
                }

                // Bottom bar
                VStack(spacing: 0) {
                    Rectangle().fill(Color.surfaceMuted).frame(height: 1)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Selected (\(selectedCount))")
                                .font(.custom("Inter_18pt-Regular", size: 12))
                                .foregroundColor(.textSecondary)
                            Text("LKR \(rowAmount(selectedTotal))")
                                .font(.custom("Inter_18pt-Bold", size: 16))
                                .foregroundColor(.primaryBlue)
                            //checking how many items arselected and the price of each item
                        }
                        Spacer()
                        Button {
                            if paymentMode == .cash {
                                showCashCounter = true
                            } else {
                                showPaymentSuccess = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if paymentMode == .cash {
                                    Image(systemName: "banknote")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                Text(paymentMode == .cash ? "Proceed with Cash" : "Pay Now")
                                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 14)
                            .background(selectedCount > 0
                                        ? (paymentMode == .cash ? Color(hex: "1B7C4E") : Color.primaryBlueDark)
                                        : Color.textTertiary)
                            .cornerRadius(12)
                        }
                        .disabled(selectedCount == 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.white)
//pay now button that can be disabled if bothing is selected
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
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onChange(of: navTab) { _, tab in
            AppRouter.shared.pendingTab = tab
            dismiss()
        }
        //removed toolbar — custom nav used instead
        .navigationDestination(isPresented: $showAddCard) {
            AddCardView { card in
                savedCards.append(card)
                paymentMode = .card(index: savedCards.count) // select the newly added card
            }
        }
        .navigationDestination(isPresented: $showPaymentSuccess) {
            BookingSuccessView(
                doctor: doctor,
                selectedDate: selectedDate,
                selectedTimeSlot: selectedTimeSlot,
                isPaid: true
            )
        }
        .navigationDestination(isPresented: $showCashCounter) {
            CashCounterView(
                totalAmount: selectedTotal,
                doctorName: doctor.name,
                itemCount: selectedCount
            )
        }
        .navigationDestination(isPresented: $navigateHome) {
            HomeView(isReturningUser: true)
                .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - helpers
    private func formattedAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
//easier views
    private func payRow(index: Int) -> some View {
        let item = items[index]
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                items[index].isSelected.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                // checkbozx fesing
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(item.isSelected ? Color.primaryBlue : Color(hex: "D1D5DB"), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if item.isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primaryBlue)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // titles
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.custom("Inter_18pt-Medium", size: 14))
                        .foregroundColor(.textPrimary)
                    Text(item.subtitle)
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // amt and due amts
                VStack(alignment: .trailing, spacing: 3) {
                Text("LKR \(rowAmount(item.amount))")
                        .font(.custom("Inter_18pt-Bold", size: 14))
                        .foregroundColor(item.isSelected ? .primaryBlue : .textTertiary)
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
    }

    private func cardOption(icon: String, label: String, isAdd: Bool, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isAdd ? .textTertiary : .primaryBlue)
                Text(label)
                    .font(.custom("Inter_18pt-Medium", size: 13))
                    .foregroundColor(isAdd ? .textTertiary : .textPrimary)
            }
            .frame(width: 110)
            .padding(.vertical, 22)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selected ? Color.primaryBlue : Color.surfaceMuted,
                            lineWidth: selected ? 2 : 1)
            )
        }
    }
}//allowed to change card and button colors

// MARK: - for backwards compatability
struct PaymentItemRow: View {
    let title: String
    let amount: Int
    let dueDate: String
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.primaryBlue : Color(hex: "D1D5DB"), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        RoundedRectangle(cornerRadius: 6).fill(Color.primaryBlue).frame(width: 22, height: 22)
                        Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.custom("Inter_18pt-Medium", size: 14)).foregroundColor(.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("LKR \(String(format: "%.2f", Double(amount)))").font(.custom("Inter_18pt-Bold", size: 14)).foregroundColor(.textPrimary)
                    Text("Due : \(dueDate)").font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(.textSecondary)
                }
            }
            .padding(16).background(Color.white).cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? Color.primaryBlue : Color.surfaceMuted, lineWidth: isSelected ? 2 : 1))
        }
    }
}

struct PaymentMethodCard: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var isAddCard: Bool = false
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                Image(systemName: icon).font(.system(size: 24)).foregroundColor(isAddCard ? .textTertiary : .textPrimary)
                Text(title).font(.custom("Inter_18pt-Medium", size: 13)).foregroundColor(isAddCard ? .textTertiary : .textPrimary)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 24).background(Color.white).cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? Color.primaryBlue : Color.surfaceMuted, lineWidth: isSelected ? 2 : 1))
        }
    }
}

#Preview {
    NavigationStack {
        PaymentView(
            doctor: MockDoctors.all[0],
            selectedDate: Date(),
            selectedTimeSlot: TimeSlot(time: "8.30 AM", bookedCount: 3, maxCount: 8),
            totalAmount: 1600
        )
    }
}
