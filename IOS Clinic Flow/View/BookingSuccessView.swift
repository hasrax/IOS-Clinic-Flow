//
//  BookingSuccessView.swift
//  IOS Clinic Flow
//
//  Created by Lakindu Siriwardena on 2026-03-09.
//

import SwiftUI

// MARK: cursor movement management
private struct CurvedBottomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 60))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY - 60),
            control: CGPoint(x: rect.midX, y: rect.maxY + 100)
        )
        path.closeSubpath()
        return path
    }
}

struct BookingSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    let doctor: Doctor
    let selectedDate: Date
    let selectedTimeSlot: TimeSlot?
    let isPaid: Bool
    //data passed from the previous page
    @State private var showPayment = false
    @State private var navigateToHome = false
    @State private var navTab: TabItem = .home
//navs to the payment and home pages
    private func formattedAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    var totalAmount: Int {
        doctor.fee + 100
    }
    
    var body: some View {
        ZStack {
            // extra design stuff to be added
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                LinearGradient.primaryGradient
                    .clipShape(CurvedBottomShape())
                    .frame(height: 460)
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Success Icon
                        ZStack {
                            Circle()
                                .fill(Color.successGreen)
                                .frame(width: 70, height: 70)
                            Image(systemName: "checkmark")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        
                        // if booking has been made this would appear since we dont have a back end yet xxxx
                        Text(isPaid ? "Successful !" : "Booking Confirmed !")
                            .font(.custom("Inter_18pt-Bold", size: 22))
                            .foregroundColor(.white)
                            .padding(.top, 16)
                        
                        // if payment has been made shows up but since no back end no show up i guess xxxx
                        Text(isPaid ? "Your Total payment has been paid\nsuccessfully" : "Your appointment has been scheduled\nsuccessfully")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        // Booking Details Card
                        BookingDetailsCard(
                            doctor: doctor,
                            selectedDate: selectedDate,
                            selectedTimeSlot: selectedTimeSlot,
                            totalAmount: totalAmount,
                            isPaid: isPaid
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        
                        if !isPaid {
                            // it not paid additional informatuon to appear
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(
                                    icon: "bell.fill",
                                    text: "You will be notified 30 min before your appointment"
                                )
                                
                                InfoRow(
                                    icon: "map.fill",
                                    text: "Use clinic map to navigate to your room on visit day"
                                )
                                
                                InfoRow(
                                    icon: "xmark.circle.fill",
                                    text: "Free cancellation up to 5 hours before appointment"
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                        }
                        
                        Spacer().frame(height: 120)
                    }
                }
                
                // Bottom Buttons
                VStack(spacing: 12) {
                    if isPaid {
                        // home button
                        Button {
                            navigateToHome = true
                        } label: {
                            Text("Go to Home")
                                .font(.custom("Inter_18pt-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.primaryBlueDark)
                                .cornerRadius(14)
                        }
                    } else {
                        // pay and go home
                        HStack(spacing: 12) {
                            Button {
                                showPayment = true
                            } label: {
                                Text("Pay Now")
                                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(LinearGradient.primaryGradient)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                navigateToHome = true
                            } label: {
                                Text("Go to home")
                                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                                    .foregroundColor(.primaryBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.primaryBlue, lineWidth: 1.5)
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                
                // Tab Bar
                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onChange(of: navTab) { _, tab in
            AppRouter.shared.pendingTab = tab
            navigateToHome = true
        }
        .navigationDestination(isPresented: $showPayment) {
            PaymentView(
                doctor: doctor,
                selectedDate: selectedDate,
                selectedTimeSlot: selectedTimeSlot,
                totalAmount: totalAmount
            )
        }
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView(isReturningUser: true)
                .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Booking Details Card used to display data only
struct BookingDetailsCard: View {
    let doctor: Doctor
    let selectedDate: Date
    let selectedTimeSlot: TimeSlot?
    let totalAmount: Int
    let isPaid: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()

    private func formattedAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    var body: some View {
        VStack(spacing: 16) {
            // Appointment Number hardcoded due to no back ebd and cant get informatio xxxx
            VStack(spacing: 4) {
                Text("Appointment No")
                    .font(.custom("Inter_18pt-Regular", size: 13))
                    .foregroundColor(.textSecondary)
                Text("BM240126-11")
                    .font(.custom("Inter_18pt-ExtraBold", size: 28))
                    .foregroundColor(.textPrimary)
            }
            .padding(.top, 20)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Doctor Info
            HStack(spacing: 12) {
                Image(doctor.avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(doctor.name)
                        .font(.custom("Inter_18pt-Bold", size: 15))
                        .foregroundColor(.textPrimary)
                    Text(doctor.specialty)
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // appointment details to be set about whats goin on
            VStack(spacing: 12) {
                DetailRow(icon: "calendar", label: "Date", value: dateFormatter.string(from: selectedDate))
                DetailRow(icon: "clock", label: "Time", value: selectedTimeSlot?.time ?? "8.30 AM")
                DetailRow(icon: "mappin", label: "Location", value: doctor.location)
                
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
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.primaryBlueTint)
                        .cornerRadius(12)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Total Amount
            HStack {
                Text(isPaid ? "Total Paid" : "Total Amount")
                    .font(.custom("Inter_18pt-Medium", size: 14))
                    .foregroundColor(.primaryBlue)
                Spacer()
                Text("LKR \(formattedAmount(totalAmount))")
                    .font(.custom("Inter_18pt-Bold", size: 16))
                    .foregroundColor(.primaryBlue)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
    }
}

// MARK: - appointment Detail Row
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
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

// MARK: - appointment Info Row
struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.textTertiary)
                .frame(width: 24)
            
            Text(text)
                .font(.custom("Inter_18pt-Regular", size: 13))
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        BookingSuccessView(
            doctor: MockDoctors.all[0],
            selectedDate: Date(),
            selectedTimeSlot: TimeSlot(time: "8.30 AM", bookedCount: 3, maxCount: 8),
            isPaid: false
        )
    }
}
