//
//  LoginView.swift
//  IOS Clinic Flow
//
//  Created by Vihanga Madushamini on 2026-03-10.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var router = AppRouter.shared  // Observes shared app router object so the UI updates when login state changes
    @State private var phoneNumber  = ""
    @State private var phoneError   = ""
    @State private var showOTP      = false // Controls whether the OTP sheet should appear
    @State private var goBack       = false
    
    var isValid: Bool { phoneNumber.filter { $0.isNumber }.count == 9 }
    
    func validateAndSend() {
        let digits = phoneNumber.filter { $0.isNumber }
        // Check validation rules
        if digits.isEmpty {
            phoneError = "Please enter your mobile number"
        } else if digits.first == "0" {
            phoneError = "Don't include leading 0 — enter 9 digits after +94"
        } else if digits.count < 9 {
            phoneError = "Number too short — must be exactly 9 digits"
        } else if digits.count > 9 {
            phoneError = "Number too long — must be exactly 9 digits"
        } else {
            phoneError = ""
            showOTP = true
        }
    }
    
    var body: some View {
        if goBack {
            LanguageView()
        }
        else if router.isLoggedIn {
            // +94 77 123 4567 - existing user number
            RootView(isFirstUser: !router.loggedInPhone.hasSuffix("771234567"))
        }
        else {
            ZStack(alignment: .bottom) {
                
                
                Color(hex: "EEF1F5").ignoresSafeArea()
                
                // Top section: back button + logo
                VStack(spacing: 0) {
                    HStack {
                        Button { goBack = true } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "1B2D6B"))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 60)
                    
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .padding(.top, 7)
                    
                    Spacer()
                }
                
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                // White card section at bottom
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Heading text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HI, WELCOME BACK")
                            .font(.custom("Inter_18pt-Bold", size: 26))
                            .foregroundColor(Color(hex: "1B2D6B"))
                        
                        Text("Verify your phone number to continue.")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(Color(hex: "8A93A6"))
                    }
                    .padding(.top, 36)
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Phone number input section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mobile Number")
                            .font(.custom("Inter_18pt-SemiBold", size: 13))
                            .foregroundColor(Color(hex: "4B5567"))
                        
                        HStack(spacing: 12) {
                            Text("+94")
                                .font(.custom("Inter_18pt-SemiBold", size: 15))
                                .foregroundColor(Color(hex: "1B2D6B"))
                            TextField("xxx xxxx xx", text: $phoneNumber) // User input field
                                .font(.custom("Inter_18pt-Regular", size: 15))
                                .foregroundColor(Color(hex: "1B2D6B"))
                                .keyboardType(.phonePad)
                                .onChange(of: phoneNumber) { val in
                                    phoneError = ""
                                    if val.filter({ $0.isNumber }).count > 9 {
                                        phoneNumber = String(val.dropLast())
                                    }
                                }
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 56)
                        .background(Color(hex: "F7F8FA"))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    phoneError.isEmpty ? Color(hex: "D8DCE6") : Color.errorRed,
                                    lineWidth: 1.5
                                )
                        )
                        
                        // Show error message only if error exists
                        if !phoneError.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.errorRed)
                                Text(phoneError)
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.errorRed)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Send code button
                    Button { validateAndSend() } label: {
                        Text("Send Code")
                            .font(.custom("Inter_18pt-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "1B2D6B"))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // OR divider
                    HStack {
                        Rectangle().fill(Color(hex: "D8DCE6")).frame(height: 1)
                        Text("OR")
                            .font(.custom("Inter_18pt-SemiBold", size: 12))
                            .foregroundColor(Color(hex: "8A93A6"))
                            .padding(.horizontal, 14)
                        Rectangle().fill(Color(hex: "D8DCE6")).frame(height: 1)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    //Social login buttons
                    HStack(spacing: 24) {
                        Spacer()
                        socialCircleBtn(icon: "G",          isSystem: false)
                        socialCircleBtn(icon: "apple.logo", isSystem: true)
                        Spacer()
                    }
                    
                    Spacer().frame(height: 70)
                }
                
                // White card takes 62% of screen height
                .frame(height: UIScreen.main.bounds.height * 0.62)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "EEF1F5"))
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 36,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 146
                    )
                )
                
                // Custom shape with large rounded top-right corner
                .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: -6)
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 36,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 146
                    )
                    .stroke(Color.black.opacity(0.07), lineWidth: 1)
                )
            }
            
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $showOTP) {
                OTPView(
                    phoneNumber: phoneNumber,
                    isPresented: $showOTP,
                    onVerified: {
                        let digits = phoneNumber.filter { $0.isNumber }
                        router.loggedInPhone = digits
                        router.isNewUser = !digits.hasSuffix("771234567")
                        router.isLoggedIn = true
                    }
                )
            }
            
            
            
           }
        
        }
    
    @ViewBuilder
        private func socialCircleBtn(icon: String, isSystem: Bool) -> some View {
            Button { } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 58, height: 58)
                        .overlay(Circle().stroke(Color(hex: "D8DCE6"), lineWidth: 1.5))
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                    if isSystem {
                        // Apple logo
                        Image("apple")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    } else {
                        // Google logo
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    
        
    }

