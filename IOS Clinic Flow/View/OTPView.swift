//
//  OTPView.swift
//  IOS Clinic Flow
//
//  Created by Vihanga Madushamini on 2026-03-10.
//

import SwiftUI
internal import Combine // Imports Combine framework for timer publisher

struct OTPView: View {
    let phoneNumber: String
    @Binding var isPresented: Bool
    let onVerified: () -> Void
    
    @State private var otpDigits  = ["", "", "", "", ""]
    @State private var countdown  = 45
    @State private var canResend  = false
    @State private var otpError   = ""
    @State private var shake      = false
    @FocusState private var focusedIndex: Int?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // Creates a timer that fires every 1 second

        var isComplete: Bool { otpDigits.allSatisfy { $0.count == 1 } }

        var maskedPhone: String {
            let digits = phoneNumber.filter { $0.isNumber }
            guard digits.count >= 4 else { return phoneNumber }
            return "+94 *** **** \(String(digits.suffix(4)))"
        }
    
    func verifyOTP() {
            let code = otpDigits.joined() // Joins all OTP boxes into one string
            if code.count < 5 {
                otpError = "Please enter all 5 digits"
                withAnimation(.default) { shake = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { shake = false }
            } else {
                otpError = ""
                isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onVerified() }
            }
        }
    
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                    
                    ZStack {
                        LinearGradient.heroGradient

                        
                        Circle()
                            .fill(Color.accentBlue.opacity(0.22))
                            .frame(width: 200, height: 200)
                            .blur(radius: 50)
                            .offset(x: 80, y: -20)

                        VStack(spacing: 12) {
                            // Lock icon badge
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 72, height: 72)
                                Circle()
                                    .fill(Color.white.opacity(0.10))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "lock.open.fill")
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundColor(.white)
                                }
                            // OTP heading
                            Text("Enter Verification Code")
                                .font(.custom("Inter_18pt-Bold", size: 19))
                                .foregroundColor(.white)

                            // phone number display
                            HStack(spacing: 6) {
                                Image(systemName: "iphone")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text(maskedPhone)
                                    .font(.custom("Inter_18pt-Medium", size: 13))
                                    .foregroundColor(.white.opacity(0.9))
                               }
                            .padding(.horizontal, 14).padding(.vertical, 6)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.2), lineWidth: 1))
                          }
                            .padding(.top, 28)
                            .padding(.bottom, 32)
                        }
                            .frame(maxWidth: .infinity)

                    // Lower content section
                    VStack(spacing: 0) {
                        // Instructional caption
                        Text("A 5-digit code was sent via SMS")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.textSecondary)
                            .padding(.top, 28)
                            .padding(.bottom, 24)

                        // OTP boxes
                        HStack(spacing: 10) {
                            ForEach(0..<5, id: \.self) { index in
                                SingleOTPBox(
                                    digit: $otpDigits[index], // Bind each box to one OTP digit
                                    isFocused: focusedIndex == index,  // Highlight current focused box
                                    hasError: !otpError.isEmpty,    // Show error style if OTP invalid
                                    onChanged: { value in
                                        otpError = ""
                                        let filtered = value.filter { $0.isNumber }   // Keep only numeric input
                                        otpDigits[index] = filtered.count > 1 ? String(filtered.last!) : filtered
                                        if !filtered.isEmpty && index < 4 { focusedIndex = index + 1 }  // Automatically move to next box after entering a digit
                                        
                                        if otpDigits.allSatisfy({ $0.count == 1 }) {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { verifyOTP() }
                                        }
                                        // If all boxes are filled, verify OTP automatically
                                    }
                                )
                                .focused($focusedIndex, equals: index)
                            }
                        }
                        .offset(x: shake ? -6 : 0)
                        .animation(shake ? .default.repeatCount(4, autoreverses: true).speed(6) : .default, value: shake)
                        .padding(.horizontal, 24)

                        // Error message
                        if !otpError.isEmpty {
                            HStack(spacing: 5) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12)).foregroundColor(.errorRed)
                                Text(otpError)
                                    .font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(.errorRed)
                            }
                            .padding(.top, 10)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                         // Resend section
                        Group {
                            if canResend {
                                Button {
                                    countdown = 45; canResend = false
                                    otpDigits = ["", "", "", "", ""]
                                    otpError  = ""; focusedIndex = 0
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text("Resend Code")
                                            .font(.custom("Inter_18pt-SemiBold", size: 14))
                                    }
                                    .foregroundColor(.primaryBlue)
                                    .padding(.horizontal, 18).padding(.vertical, 8)
                                    .background(Color.primaryBlueTint)
                                    .cornerRadius(20)
                                }
                            } else {
                                HStack(spacing: 6) {
                                    Text("Resend in")
                                        .font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(.textSecondary)
                                    ZStack {
                                        Circle()
                                            .trim(from: 0, to: CGFloat(countdown) / 45)
                                            .stroke(Color.primaryBlue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                            .frame(width: 28, height: 28)
                                            .rotationEffect(.degrees(-90))
                                        Text("\(countdown)")
                                            .font(.custom("Inter_18pt-Bold", size: 11))
                                            .foregroundColor(.primaryBlue)
                                    }
                                }
                            }
                        }
                        .padding(.top, 18)
                        .padding(.bottom, 30)

                        // Verify button
                        Button { verifyOTP() } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        isComplete
                                        ? LinearGradient.primaryGradient
                                        : LinearGradient(colors: [Color.textLight],
                                                         startPoint: .leading, endPoint: .trailing)
                                    )
                                    .shadow(color: isComplete ? Color.accentBlue.opacity(0.40) : .clear,
                                            radius: 12, x: 0, y: 5)
                                HStack(spacing: 10) {
                                    Text("Verify & Continue")
                                        .font(.custom("Inter_18pt-Bold", size: 16))
                                        .foregroundColor(.white)
                                    ZStack {
                                        Circle().fill(Color.white.opacity(0.20)).frame(width: 28, height: 28)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity).frame(height: 56)
                        }
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                    .background(Color.appBackground)
                }

            // Close button at top right
                VStack {
                    HStack {
                        Spacer()
                        Button { isPresented = false } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 30, height: 30)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Circle())
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
            .presentationDetents([.fraction(0.70)])
            .presentationDragIndicator(.hidden)
            .onReceive(timer) { _ in
                if countdown > 0 { countdown -= 1 } else { canResend = true }
            }
            .onAppear { focusedIndex = 0 }
        }
}

//separate reusable OTP input box component.
struct SingleOTPBox: View {
    @Binding var digit: String
    let isFocused: Bool
    var hasError: Bool = false
    let onChanged: (String) -> Void

    var body: some View {
        TextField("", text: $digit)
            .font(.custom("Inter_18pt-Bold", size: 22))
            .foregroundColor(hasError ? .errorRed : Color.textPrimary)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(hasError ? Color.errorTint : Color.primaryBlueTint)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        hasError  ? Color.errorRed :
                        isFocused ? Color.primaryBlue : Color.borderLight,
                        lineWidth: 1.5
                    )
            )
            
            .onChange(of: digit) { _, newValue in onChanged(newValue) }
    }
}
