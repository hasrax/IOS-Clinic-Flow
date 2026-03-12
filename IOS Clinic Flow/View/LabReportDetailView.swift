//
//  LabReportDetailView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-09.
//

import SwiftUI

// MARK: - LabRow model
//single rows
private struct LabRow: Identifiable {
    let id = UUID()
    let test: String
    let result: String
    let reference: String
    let statusIcon: String  //ex: checkmark.circle.fill
    let statusColor: Color
}

struct LabReportDetailView: View {
    @Environment(\.dismiss) private var dismiss// go back - dismiss action
    @State private var navTab: TabItem = .home

    // mock data for the lab results to display
    private let labRows: [LabRow] = [
        LabRow(test: "Color",   result: "Pale Yellow", reference: "Pale Yellow", statusIcon: "checkmark.circle.fill", statusColor: Color(hex: "22C55E")),
        LabRow(test: "pH",      result: "6.0",         reference: "4.5 – 8.0",   statusIcon: "checkmark.circle.fill", statusColor: Color(hex: "22C55E")),
        LabRow(test: "Protein", result: "Negative",    reference: "Negative",    statusIcon: "checkmark.circle.fill", statusColor: Color(hex: "22C55E")),
        LabRow(test: "Glucose", result: "Negative",    reference: "Negative",    statusIcon: "checkmark.circle.fill", statusColor: Color(hex: "22C55E")),
        LabRow(test: "WBC",     result: "2-3 /HPF",    reference: "0-5 /HPF",    statusIcon: "checkmark.circle.fill", statusColor: Color(hex: "22C55E")),
        LabRow(test: "RBC",     result: "0-1 /HPF",    reference: "0-2 /HPF",    statusIcon: "checkmark.circle.fill", statusColor: Color(hex: "22C55E")),
    ]

    // To show the doctor's notes bullet points
    private let doctorNotes = [
        "Results are within acceptable range.",
        "Continue with current medication.",
        "Schedule a follow-up in 3 months for re-evaluation.",
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    //custom back button
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                    Text("Urinalysis Report")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Spacer().frame(width: 38)
                }
                //to keep the centered title
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Header summary card
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(LinearGradient.primaryGradientDeep)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("LAB-0088")
                                    .font(.custom("Inter_18pt-SemiBold", size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("Urinalysis")
                                    .font(.custom("Inter_18pt-Black", size: 22))
                                    .foregroundColor(.white)
                                Text("Feb 20, 2026 - 11:30 AM")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                HStack(spacing: 6) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("Dr. Samantha Perera")
                                        .font(.custom("Inter_18pt-Medium", size: 13))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                            .padding(20)
                        }
                        .padding(.horizontal, 16)

                        // Test results
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Test Results")
                                .font(.custom("Inter_18pt-Bold", size: 16))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 16)

                            VStack(spacing: 0) {
                                // Header row
                                HStack {
                                    Text("TEST")
                                    Spacer()
                                    Text("RESULT")
                                    Spacer()
                                    Text("REFERENCE")
                                    Spacer()
                                    Text("STATUS")
                                }
                                .font(.custom("Inter_18pt-SemiBold", size: 10))
                                .foregroundColor(.textTertiary)
                                .tracking(0.6)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(hex: "F9FAFB"))

                                Divider()

                                ForEach(Array(labRows.enumerated()), id: \.element.id) { idx, row in
                                    HStack {
                                        Text(row.test)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(row.result)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(row.reference)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Image(systemName: row.statusIcon)
                                            .foregroundColor(row.statusColor)
                                            .font(.system(size: 16))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.textPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 11)
                                    .background(idx % 2 == 0 ? Color.white : Color(hex: "FAFAFA"))

                                    if idx < labRows.count - 1 { Divider() }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borderMedium, lineWidth: 1))
                            .padding(.horizontal, 16)

                            // Legend- the items explaning the colors
                            HStack(spacing: 20) {
                                legendDot(color: Color(hex: "22C55E"), label: "Normal")
                                legendDot(color: Color(hex: "EF4444"), label: "Above Range")
                                legendDot(color: Color(hex: "F59E0B"), label: "Below Range")
                            }
                            .padding(.horizontal, 20)
                        }

                        // Doctor notes card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Doctor's Notes")
                                .font(.custom("Inter_18pt-Bold", size: 15))
                                .foregroundColor(.textPrimary)

                            VStack(alignment: .leading, spacing: 7) {
                                ForEach(doctorNotes, id: \.self) { note in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .font(.custom("Inter_18pt-Regular", size: 13))
                                            .foregroundColor(.textSecondary)
                                        Text(note)
                                            .font(.custom("Inter_18pt-Regular", size: 13))
                                            .foregroundColor(.textSecondary)
                                    }
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

                        // Action buttons
                        VStack(spacing: 10) {
                            Button {} label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.down.to.line")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("Download Full Report (PDF)")
                                        .font(.custom("Inter_18pt-Bold", size: 15))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(LinearGradient.primaryGradient)
                                .cornerRadius(14)
                            }

                            Button {} label: {
                                Text("Share with Another Doctor")
                                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                                    .foregroundColor(.primaryBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.primaryBlue, lineWidth: 1.5)
                                    )
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 4)
                }

                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 11))
                .foregroundColor(.textSecondary)
        }
    }
}
