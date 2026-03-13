//
//  PrescriptionsView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-09.
//

import SwiftUI

// MARK: - Prescription Record data model
private struct PrescriptionRecord: Identifiable {
    let id = UUID()
    let doctor: String
    let specialty: String
    let date: String
    let medications: [String]
    let refills: Int
    let status: String   // "Active" | "Completed" | "Expired"
}

//mock data for that
private let mockRx: [PrescriptionRecord] = [
    PrescriptionRecord(doctor: "Dr. Samantha Perera",   specialty: "General Physician", date: "Feb 20, 2026",
                       medications: ["Amoxicillin 500mg", "Paracetamol 650mg"], refills: 2, status: "Active"),
    PrescriptionRecord(doctor: "Dr. Nimal Fernando",    specialty: "Cardiology",        date: "Jan 15, 2026",
                       medications: ["Atorvastatin 40mg", "Aspirin 75mg", "Metoprolol 25mg"], refills: 0, status: "Active"),
    PrescriptionRecord(doctor: "Dr. Kamal Jayasinghe",  specialty: "Pulmonology",       date: "Dec 10, 2025",
                       medications: ["Salbutamol Inhaler", "Budesonide 200mcg"], refills: 1, status: "Completed"),
    PrescriptionRecord(doctor: "Dr. Nipun Wijesinghe",  specialty: "Neurology",         date: "Nov 5, 2025",
                       medications: ["Pregabalin 75mg"], refills: 0, status: "Expired"),
]

// tabs names
private let rxFilters = ["All", "Active", "Completed", "Expired"]

struct PrescriptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var router = AppRouter.shared
    @State private var selectedFilter = "All"

    private var filtered: [PrescriptionRecord] {
        selectedFilter == "All" ? mockRx : mockRx.filter { $0.status == selectedFilter }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
              
                NavBar(
                    title: "Prescriptions",
                    onBack: { dismiss() },
                    backColor: .primaryBlue,
                    titleColor: .primaryBlue
                )

                
                if router.isNewUser {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "pills.fill")
                            .font(.system(size: 52))
                            .foregroundColor(Color(hex: "D8DCE6"))
                        Text("No prescriptions yet")
                            .font(.custom("Inter_18pt-Bold", size: 18))
                            .foregroundColor(.textPrimary)
                        Text("Your prescriptions will appear here\nafter your first consultation")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(rxFilters, id: \.self) { f in
                                Button { selectedFilter = f } label: {
                                    Text(f)
                                        .font(.custom("Inter_18pt-Medium", size: 13))
                                        .foregroundColor(selectedFilter == f ? .white : .textSecondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == f ? Color.primaryBlue : Color.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(filtered) { rx in
                                rxCard(rx)
                            }
                            Spacer().frame(height: 40)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func rxCard(_ rx: PrescriptionRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(rx.doctor)
                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                        .foregroundColor(.textPrimary)
                    Text(rx.specialty)
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                statusBadge(rx.status)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                ForEach(rx.medications, id: \.self) { med in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.primaryBlueTint)
                            .frame(width: 6, height: 6)
                        Text(med)
                            .font(.custom("Inter_18pt-Regular", size: 13))
                            .foregroundColor(.textPrimary)
                    }
                }
            }

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                    Text(rx.date)
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                if rx.refills > 0 {
                    Text("\(rx.refills) refill\(rx.refills > 1 ? "s" : "") left")
                        .font(.custom("Inter_18pt-Medium", size: 12))
                        .foregroundColor(.primaryBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.primaryBlueTint)
                        .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func statusBadge(_ status: String) -> some View {
        let (fg, bg): (Color, Color) = {
            switch status {
            case "Active":    return (.successGreen, Color(hex: "22C55E").opacity(0.10))
            case "Completed": return (.primaryBlue,  Color.primaryBlue.opacity(0.08))
            default:          return (.errorRed,     Color(hex: "EF4444").opacity(0.08))
            }
        }()
        return Text(status)
            .font(.custom("Inter_18pt-Medium", size: 12))
            .foregroundColor(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(bg)
            .cornerRadius(10)
    }
}

