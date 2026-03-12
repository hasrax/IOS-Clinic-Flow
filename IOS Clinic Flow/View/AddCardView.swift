//
//  AddCardView.swift
//  IOS Clinic Flow
//
//  Created by Lakindu Siriwardena on 2026-03-11.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    var onCardAdded: ((SavedCard) -> Void)? = nil

    @State private var cardNumber   = ""
    @State private var cardHolder   = ""
    @State private var expiry       = ""
    @State private var cvv          = ""
    @State private var showCVV      = false
    @State private var isFlipped    = false
    @State private var navTab: TabItem = .home

    // card nuber with spaces after 4 numbers are written down
    private var formattedCard: String {
        let digits = cardNumber.filter(\.isNumber).prefix(16)
        var result = ""
        for (i, ch) in digits.enumerated() {
            if i != 0 && i % 4 == 0 { result += " " }
            result.append(ch)
        }
        return result
    }

    private var maskedDisplay: String {
        let d = cardNumber.filter(\.isNumber)
        guard !d.isEmpty else { return "**** **** **** ****" }
        let visible = d.suffix(4)
        let hidden  = String(repeating: "*", count: max(0, 16 - visible.count))
        var raw = hidden + visible
        var r = ""
        for (i, ch) in raw.enumerated() {
            if i != 0 && i % 4 == 0 { r += " " }
            r.append(ch)
        }
        return r
    }

    private var holderDisplay: String {
        cardHolder.isEmpty ? "FULL NAME" : cardHolder.uppercased()
    }

    private var expiryDisplay: String {
        expiry.isEmpty ? "MM/YY" : expiry
    }

    private var networkIcon: String {
        let digits = cardNumber.filter(\.isNumber)
        if digits.hasPrefix("4") { return "Visa" }
        if digits.hasPrefix("5") { return "Mastercard" }
        return ""
    }

    private var canSave: Bool {
        cardNumber.filter(\.isNumber).count == 16 &&
        !cardHolder.trimmingCharacters(in: .whitespaces).isEmpty &&
        expiry.count == 5 &&
        cvv.count >= 3
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom nav bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    Spacer()
                    Text("Add Card")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // card preview
                        ZStack {
                            // Front
                            cardFront
                                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (0, 1, 0))
                                .opacity(isFlipped ? 0 : 1)

                            // Back
                            cardBack
                                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (0, 1, 0))
                                .opacity(isFlipped ? 1 : 0)
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isFlipped)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // input feilds and stff
                        VStack(spacing: 16) {

                            // Card Number
                            inputField(
                                label: "Card Number",
                                placeholder: "1234 5678 9012 3456",
                                text: Binding(
                                    get: { formattedCard },
                                    set: { new in
                                        let digits = new.filter(\.isNumber)
                                        if digits.count <= 16 { cardNumber = digits }
                                    }
                                ),
                                icon: "creditcard",
                                keyboard: .numberPad,
                                onFocus: { isFlipped = false }
                            )

                            //  name of card user
                            inputField(
                                label: "Cardholder Name",
                                placeholder: "Name as on card",
                                text: $cardHolder,
                                icon: "person",
                                keyboard: .default,
                                onFocus: { isFlipped = false }
                            )

                            HStack(spacing: 14) {
                                // Expiry info
                                inputField(
                                    label: "Expiry Date",
                                    placeholder: "MM/YY",
                                    text: Binding(
                                        get: { expiry },
                                        set: { new in
                                            let digits = new.filter(\.isNumber).prefix(4)
                                            var r = ""
                                            for (i, ch) in digits.enumerated() {
                                                if i == 2 { r += "/" }
                                                r.append(ch)
                                            }
                                            expiry = r
                                        }
                                    ),
                                    icon: "calendar",
                                    keyboard: .numberPad,
                                    onFocus: { isFlipped = false }
                                )

                                // CVV
                                inputField(
                                    label: "CVV",
                                    placeholder: "•••",
                                    text: Binding(
                                        get: { cvv },
                                        set: { new in
                                            let d = new.filter(\.isNumber)
                                            if d.count <= 4 { cvv = d }
                                        }
                                    ),
                                    icon: "lock",
                                    keyboard: .numberPad,
                                    isSecure: !showCVV,
                                    trailingIcon: showCVV ? "eye.slash" : "eye",
                                    trailingAction: { showCVV.toggle() },
                                    onFocus: { isFlipped = true }
                                )
                            }

                            // Accepted cards hint
                            HStack(spacing: 10) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.successGreen)
                                Text("Your card details are encrypted and secure")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 100)
                    }
                }

                // design for the add card bbutton and stiff
                VStack(spacing: 0) {
                    Rectangle().fill(Color.surfaceMuted).frame(height: 1)
                    Button {
                        let last4 = String(cardNumber.filter(\.isNumber).suffix(4))
                        let net   = networkIcon.isEmpty ? "Card" : networkIcon
                        let card  = SavedCard(
                            label: "\(net) ****\(last4)",
                            icon:  networkIcon == "Visa" ? "visa_icon" : "creditcard.fill"
                        )
                        onCardAdded?(card)
                        dismiss()
                    } label: {
                        Text("Add Card")
                            .font(.custom("Inter_18pt-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSave ? Color.primaryBlueDark : Color.textTertiary)
                            .cornerRadius(14)
                    }
                    .disabled(!canSave)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onChange(of: navTab) { _, tab in
            AppRouter.shared.pendingTab = tab
            dismiss()
        }
    }

    // MARK: - design for the front of the card
    private var cardFront: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient.primaryGradientDeep)
                .frame(height: 200)

            // circles in the card
            Circle().fill(Color.white.opacity(0.07)).frame(width: 160).offset(x: -50, y: -50)
            Circle().fill(Color.white.opacity(0.05)).frame(width: 120).offset(x: 240, y: 80)

            VStack(alignment: .leading, spacing: 0) {
                // chip and netword icon desing
                HStack {
                    // Chip
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "F5D060"), Color(hex: "C8993E")]),
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 32)
                        Path { p in
                            p.move(to: CGPoint(x: 22, y: 4))
                            p.addLine(to: CGPoint(x: 22, y: 28))
                        }
                        .stroke(Color(hex: "C8993E").opacity(0.6), lineWidth: 1)
                        Path { p in
                            p.move(to: CGPoint(x: 4, y: 16))
                            p.addLine(to: CGPoint(x: 40, y: 16))
                        }
                        .stroke(Color(hex: "C8993E").opacity(0.6), lineWidth: 1)
                    }

                    Spacer()

                    if !networkIcon.isEmpty {
                        Text(networkIcon)
                            .font(.custom("Inter_18pt-Bold", size: 22))
                            .foregroundColor(.white)
                            .italic()
                    }
                }
                .padding(.top, 22)
                .padding(.horizontal, 22)

                Spacer()

                // cardnumber
                Text(maskedDisplay)
                    .font(.custom("Inter_18pt-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .tracking(2)
                    .padding(.horizontal, 22)

                Spacer().frame(height: 14)

                // name and exp date
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("CARD HOLDER")
                            .font(.custom("Inter_18pt-Regular", size: 9))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(1)
                        Text(holderDisplay)
                            .font(.custom("Inter_18pt-SemiBold", size: 13))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("EXPIRES")
                            .font(.custom("Inter_18pt-Regular", size: 9))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(1)
                        Text(expiryDisplay)
                            .font(.custom("Inter_18pt-SemiBold", size: 13))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 22)
            }
        }
        .shadow(color: Color.primaryBlueDark.opacity(0.35), radius: 20, x: 0, y: 10)
    }

    // MARK: - design for the back of the card
    private var cardBack: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient.primaryGradientDeep)
                .frame(height: 200)

            VStack(spacing: 0) {
                // Magnetic strip
                Rectangle()
                    .fill(Color.black.opacity(0.7))
                    .frame(height: 44)
                    .padding(.top, 30)

                Spacer().frame(height: 16)

                HStack {
                    Rectangle()
                        .fill(Color.surfaceMuted)
                        .frame(height: 40)

                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 70, height: 40)
                        Text(cvv.isEmpty ? "•••" : cvv)
                            .font(.custom("Inter_18pt-Bold", size: 16))
                            .foregroundColor(.textPrimary)
                            .tracking(4)
                    }
                }
                .padding(.horizontal, 22)

                Spacer().frame(height: 12)

                HStack {
                    Spacer()
                    Text("CVV")
                        .font(.custom("Inter_18pt-Regular", size: 10))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.trailing, 22)
                }

                Spacer()
            }
        }
        .shadow(color: Color.primaryBlueDark.opacity(0.35), radius: 20, x: 0, y: 10)
    }

    // MARK: - design for the input feilds and stuff
    @ViewBuilder
    private func inputField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        icon: String,
        keyboard: UIKeyboardType,
        isSecure: Bool = false,
        trailingIcon: String? = nil,
        trailingAction: (() -> Void)? = nil,
        onFocus: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.custom("Inter_18pt-Medium", size: 13))
                .foregroundColor(.textSecondary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(.primaryBlue)
                    .frame(width: 20)

                if isSecure {
                    SecureField(placeholder, text: text)
                        .font(.custom("Inter_18pt-Regular", size: 15))
                        .foregroundColor(.textPrimary)
                        .keyboardType(keyboard)
                        .onTapGesture { onFocus() }
                } else {
                    TextField(placeholder, text: text)
                        .font(.custom("Inter_18pt-Regular", size: 15))
                        .foregroundColor(.textPrimary)
                        .keyboardType(keyboard)
                        .onTapGesture { onFocus() }
                }

                if let tIcon = trailingIcon {
                    Button { trailingAction?() } label: {
                        Image(systemName: tIcon)
                            .font(.system(size: 14))
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.surfaceMuted, lineWidth: 1)
            )
        }
    }
}

// MARK: - save card model thingie
struct SavedCard: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
}

#Preview {
    NavigationStack {
        AddCardView()
    }
}
