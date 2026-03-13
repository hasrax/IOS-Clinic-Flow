//
//  CashCounterView.swift
//  IOS Clinic Flow
//

import SwiftUI

struct CashCounterView: View {
    @Environment(\.dismiss) private var dismiss
    let totalAmount: Int
    let doctorName: String
    let itemCount: Int

    @State private var navigateHome = false
    @State private var navTab: TabItem = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // ── Blue header ──────────────────────────────────────────
                        VStack(spacing: 12) {
                            Spacer().frame(height: 60)

                            // Minimal success badge
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.successGreen)
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                Text("Payment Registered")
                                    .font(.custom("Inter_18pt-SemiBold", size: 14))
                                    .foregroundColor(.successGreen)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())

                            Text("Head to the Counter")
                                .font(.custom("Inter_18pt-ExtraBold", size: 22))
                                .foregroundColor(.white)

                            Text("Show this screen and pay at the\nbilling counter below.")
                                .font(.custom("Inter_18pt-Regular", size: 13))
                                .foregroundColor(.white.opacity(0.80))
                                .multilineTextAlignment(.center)

                            Spacer().frame(height: 28)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient.primaryGradient
                                .ignoresSafeArea(edges: .top)
                                .clipShape(UnevenRoundedRectangle(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 28,
                                    bottomTrailingRadius: 28,
                                    topTrailingRadius: 0,
                                    style: .continuous
                                ))
                        )

                        // ── Counter callout card ─────────────────────────────────
                        VStack(spacing: 0) {

                            // Counter number hero
                            VStack(spacing: 8) {
                                Text("YOUR COUNTER")
                                    .font(.custom("Inter_18pt-SemiBold", size: 11))
                                    .foregroundColor(.textTertiary)
                                    .tracking(1.4)
                                    .padding(.top, 22)

                                Text("3")
                                    .font(.custom("Inter_18pt-Black", size: 72))
                                    .foregroundColor(.primaryBlue)
                                    .lineLimit(1)

                                HStack(spacing: 5) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(.primaryBlue)
                                    Text("Ground Floor, Billing Section")
                                        .font(.custom("Inter_18pt-Medium", size: 12))
                                        .foregroundColor(.textSecondary)
                                }
                                .padding(.bottom, 18)
                            }
                            .frame(maxWidth: .infinity)

                            Divider().padding(.horizontal, 16)

                            // Amount row
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Amount to Pay")
                                        .font(.custom("Inter_18pt-Regular", size: 12))
                                        .foregroundColor(.textSecondary)
                                    Text("\(itemCount) item\(itemCount == 1 ? "" : "s")"  )
                                        .font(.custom("Inter_18pt-Regular", size: 11))
                                        .foregroundColor(.textTertiary)
                                }
                                Spacer()
                                Text("LKR \(formattedAmount(totalAmount))")
                                    .font(.custom("Inter_18pt-Black", size: 20))
                                    .foregroundColor(.primaryBlue)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)

                            Divider().padding(.horizontal, 16)

                            // Doctor row
                            HStack(spacing: 10) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.accentBlue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(doctorName)
                                        .font(.custom("Inter_18pt-SemiBold", size: 14))
                                        .foregroundColor(.textPrimary)
                                    Text("Consultation")
                                        .font(.custom("Inter_18pt-Regular", size: 12))
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                                // Cash badge
                                HStack(spacing: 4) {
                                    Image(systemName: "banknote")
                                        .font(.system(size: 11))
                                        .foregroundColor(.successGreen)
                                    Text("Cash")
                                        .font(.custom("Inter_18pt-SemiBold", size: 12))
                                        .foregroundColor(.successGreen)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule().fill(Color.successGreen.opacity(0.12))
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)

                            Divider().padding(.horizontal, 16)

                            // Instructions
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Show this screen at the counter", systemImage: "info.circle")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.textSecondary)
                                Label("Payment must be completed within 30 minutes", systemImage: "clock")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.textSecondary)
                                Label("Keep your receipt after payment", systemImage: "doc.text")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // ── CTA button ───────────────────────────────────────────
                        Button { navigateHome = true } label: {
                            Text("Okay, Heading There")
                                .font(.custom("Inter_18pt-Bold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(LinearGradient.primaryGradient)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        Spacer().frame(height: 100)
                    }
                }

                BottomTabBar(selectedTab: $navTab, isNeutral: true) { tab in
                    AppRouter.shared.pendingTab = tab
                    if tab == .home {
                        navigateHome = true
                    } else {
                        dismiss()
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark) // white status bar icons over blue header
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; navigateHome = true }
        .navigationDestination(isPresented: $navigateHome) {
            HomeView(isReturningUser: true)
                .preferredColorScheme(.light)
                .navigationBarBackButtonHidden(true)
        }
    }

    private func formattedAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

#Preview {
    NavigationStack {
        CashCounterView(totalAmount: 1800, doctorName: "Dr. Anil Ranasinghe", itemCount: 2)
    }
}
