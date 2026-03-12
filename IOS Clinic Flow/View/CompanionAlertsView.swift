//
//  CompanionAlertsView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-10.
//

import SwiftUI

struct CompanionAlertsView: View {
    @Environment(\.dismiss) private var dismiss
    let person: CareForPerson
    @State private var navTab: TabItem = .home

    private func alertIcon(type: String) -> (String, Color) {
        switch type {
        case "queue": return ("person.crop.circle.badge.clock", .primaryBlue)
        case "appointment": return ("calendar.badge.checkmark", .successGreen)
        case "lab": return ("flask.fill", .purpleAccent)
        case "pharmacy": return ("pills.fill", .cyanAccent)
        default: return ("bell.fill", .warningAmber)
        }
    }
//background with nav bar
    var body: some View {
        ZStack {
            Color(hex: "F0F2F5").ignoresSafeArea()
            VStack(spacing: 0) {
                // NavBar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text(person.name)
                            .font(.custom("Inter_18pt-Bold", size: 17))
                            .foregroundColor(.textPrimary)
                        Text("Alerts")
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(hex: "F0F2F5"))

                //show and empty state
                if person.alerts.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.textLight)
                        Text("No alerts yet")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(person.alerts) { alert in
                                alertCard(alert: alert)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            BottomTabBar(selectedTab: $navTab, isNeutral: true)
        }
        .navigationBarHidden(true)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
    }

    // single row that shows the details
    private func alertCard(alert: CompanionAlert) -> some View {
        let (icon, color) = alertIcon(type: alert.type)
        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.text)
                    .font(.custom("Inter_18pt-Medium", size: 14))
                    .foregroundColor(.textPrimary)
                Text(alert.time)
                    .font(.custom("Inter_18pt-Regular", size: 12))
                    .foregroundColor(.textSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}


