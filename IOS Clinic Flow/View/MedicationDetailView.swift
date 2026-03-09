//
//  MedicationDetailView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-09.
//

import SwiftUI

// MARK: - MedicationDetailView
// Detailed view for a single dispensed medication from a pharmacy order.
// Shows dosage instructions, daily schedule, and safety warnings.
// Accessed from PharmacyView by tapping a medication card.
struct MedicationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let medication: PharmacyMedItem
    @State private var navTab: TabItem = .home  // drives BottomTabBar; onChange triggers tab switch

    /// General taking instructions displayed in the "Instructions" card.
    private let instructions = [
        "Take after meals. Complete the full course even if you feel better."
    ]
    /// Per-meal schedule entries shown in the "Daily Schedule" card.
    private let dailySchedule = [
        "Morning — After breakfast",
        "Afternoon — After lunch",
        "Night — After dinner"
    ]
    /// Safety alert bullet points shown in the "Warnings" card.
    private let warnings = [
        "Do not consume alcohol while taking this medication.",
        "Store in a cool, dry place away from sunlight.",
        "Consult your doctor if symptoms persist after 3 days"
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
                    Text("Medication Details")
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
                        // Header card
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(LinearGradient.primaryGradientDeep)
                            VStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .frame(width: 52, height: 52)
                                    Image(systemName: "pills.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.purpleAccent)
                                }
                                Text(medication.name)
                                    .font(.custom("Inter_18pt-ExtraBold", size: 20))
                                    .foregroundColor(.white)
                                Text("\(medication.dosage.capitalized) · \("7 Days")")
                                    .font(.custom("Inter_18pt-Regular", size: 13))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            .padding(.vertical, 24)
                        }
                        .padding(.horizontal, 16)

                        // Quantity | Price
                        HStack(spacing: 12) {
                            statCard(label: "QUANTITY", value: "\(medication.qty)", valueColor: .primaryBlue)
                            statCard(label: "PRICE", value: "LKR \(medication.price)", valueColor: .primaryBlue)
                        }
                        .padding(.horizontal, 16)

                        // Prescribed By / Date
                        VStack(alignment: .leading, spacing: 12) {
                            labeledField(label: "Prescribed By", value: "Dr. Samantha Perera")
                            Divider()
                            labeledField(label: "Date", value: "Feb 23, 2026")
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)

                        // Instructions (amber)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Instructions")
                                .font(.custom("Inter_18pt-Bold", size: 14))
                                .foregroundColor(Color(hex: "D97706"))
                            ForEach(instructions, id: \.self) { note in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("•").foregroundColor(Color(hex: "D97706"))
                                    Text(note)
                                        .font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(.textPrimary)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "FFFBEB"))
                        )
                        .padding(.horizontal, 16)

                        // Daily schedule
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Daily Schedule")
                                .font(.custom("Inter_18pt-Bold", size: 14))
                                .foregroundColor(.textPrimary)
                            ForEach(dailySchedule, id: \.self) { item in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("•").foregroundColor(.textSecondary)
                                    Text(item)
                                        .font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)

                        // Important warnings (red border)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Important Warnings")
                                .font(.custom("Inter_18pt-Bold", size: 14))
                                .foregroundColor(Color(hex: "DC2626"))
                            ForEach(warnings, id: \.self) { w in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("•").foregroundColor(Color(hex: "DC2626"))
                                    Text(w)
                                        .font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(hex: "EF4444"), lineWidth: 1.5)
                                )
                        )
                        .padding(.horizontal, 16)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 4)
                }

                BottomTabBar(selectedTab: $navTab)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
    }

    /// Builds a centred statistic tile showing a label (caps) and a coloured value.
    /// Used for the Quantity and Price stat pair below the header card.
    private func statCard(label: String, value: String, valueColor: Color) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.custom("Inter_18pt-SemiBold", size: 10))
                .foregroundColor(.textTertiary)
                .tracking(1)
            Text(value)
                .font(.custom("Inter_18pt-ExtraBold", size: 20))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }

    /// Builds a stacked label-value pair used in the Prescribed By / Date card.
    private func labeledField(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 11))
                .foregroundColor(.textTertiary)
            Text(value)
                .font(.custom("Inter_18pt-Bold", size: 14))
                .foregroundColor(.textPrimary)
        }
    }
}

