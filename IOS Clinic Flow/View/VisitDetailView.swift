//
//  VisitDetailView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-09.
//

import SwiftUI

// MARK: - VisitDetailView

struct VisitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navTab: TabItem = .home

    private let visitStepLabels = [
        "Registrations", "Consultations", "Lab Tests (2)", "Pharmacy", "Payment"
    ]

    private let billItems: [(String, Int)] = [
        ("Consultation Fee", 1500),
        ("Lab - CBC Test", 500),
        ("Lab - Lipid Profile", 300),
        ("Pharmacy - 3 Medications", 200),
        ("Service Charge", 900),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
                                .frame(width: 38, height: 38)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    Spacer()
                    Text("Visit Details")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Spacer().frame(width: 38)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Total cost
                        totalCostCard.padding(.horizontal, 16)

                        // Doctor info
                        doctorInfoCard.padding(.horizontal, 16)

                        // Visit steps
                        visitStepsCard.padding(.horizontal, 16)

                        // Bill breakdown
                        billBreakdownCard.padding(.horizontal, 16)

                        // Action buttons
                        VStack(spacing: 12) {
                            Button {} label: {
                                Text("Book Again With Dr Hasra Jackson")
                                    .font(.custom("Inter_18pt-Bold", size: 15))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(LinearGradient.primaryGradient)
                                    .cornerRadius(14)
                            }
                            Button {} label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.down.doc")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("Download Receipt")
                                        .font(.custom("Inter_18pt-Bold", size: 15))
                                }
                                .foregroundColor(.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.primaryBlue, lineWidth: 1.5)
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 8)
                }

                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
    }

    // MARK: - Total Cost Card
    private var totalCostCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient.primaryGradientDeep)

            VStack(spacing: 10) {
                Text("TOTAL VISIT COST")
                    .font(.custom("Inter_18pt-SemiBold", size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1.5)

                Text("LKR 9,340")
                    .font(.custom("Inter_18pt-Black", size: 34))
                    .foregroundColor(.white)

                Text("Paid")
                    .font(.custom("Inter_18pt-SemiBold", size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.successGreen))
            }
            .padding(.vertical, 24)
        }
    }

    // MARK: - Doctor Info Card
    private var doctorInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image("doctor_kamal")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.borderMedium, lineWidth: 1))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Dr. Hasra Gunawardena")
                        .font(.custom("Inter_18pt-Bold", size: 15))
                        .foregroundColor(.textPrimary)
                    Text("General Medicine")
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                    Text("Completed")
                        .font(.custom("Inter_18pt-SemiBold", size: 11))
                }
                .foregroundColor(.successGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "22C55E").opacity(0.10)))
            }

            Divider().padding(.vertical, 14)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                visitInfoCell(icon: "calendar", label: "Date", value: "FEB 23, 2024")
                visitInfoCell(icon: "clock", label: "Time", value: "2:30 PM")
                visitInfoCell(icon: "mappin.circle", label: "Location", value: "Room 204, Floor 2")
                visitInfoCell(icon: "doc.text", label: "Token", value: "BM240126-11")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private func visitInfoCell(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.custom("Inter_18pt-Regular", size: 11))
                    .foregroundColor(.textTertiary)
                Text(value)
                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                    .foregroundColor(.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Visit Steps Card

    private var visitStepsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Visit Steps")
                .font(.custom("Inter_18pt-Bold", size: 16))
                .foregroundColor(.textPrimary)

            VStack(spacing: 0) {
                ForEach(Array(visitStepLabels.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: 14) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(Color.successGreen)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            if index < visitStepLabels.count - 1 {
                                Rectangle()
                                    .fill(Color.successGreen.opacity(0.35))
                                    .frame(width: 2, height: 26)
                            }
                        }
                        Text(step)
                            .font(.custom("Inter_18pt-SemiBold", size: 14))
                            .foregroundColor(.textPrimary)
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Billing Card
    //for each services
    private var billBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Visit Steps")
                .font(.custom("Inter_18pt-Bold", size: 16))
                .foregroundColor(.textPrimary)

            VStack(spacing: 10) {
                ForEach(billItems, id: \.0) { label, amount in
                    HStack {
                        Text(label)
                            .font(.custom("Inter_18pt-Regular", size: 13))
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text("LKR  \(amount.formatted())")
                            .font(.custom("Inter_18pt-Medium", size: 13))
                            .foregroundColor(.textPrimary)
                    }
                }
            }

            Divider()

            HStack {
                Text("TOTAL")
                    .font(.custom("Inter_18pt-Bold", size: 14))
                    .foregroundColor(.textPrimary)
                    .tracking(0.5)
                Spacer()
                Text("LKR 3,500")
                    .font(.custom("Inter_18pt-Black", size: 18))
                    .foregroundColor(.primaryBlue)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

