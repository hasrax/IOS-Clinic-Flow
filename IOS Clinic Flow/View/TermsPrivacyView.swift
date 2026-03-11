//
//  TermsPrivacyView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-11.
//

import SwiftUI

struct TermsPrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSegment = 0   // 0 = Terms of Use, 1 = Privacy Policy

    private let segments = ["Terms of Use", "Privacy Policy"]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                //NavBar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    Spacer()
                    Text("Terms & Privacy")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.primaryBlue)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                //Segment
                HStack(spacing: 0) {
                    ForEach(segments.indices, id: \.self) { i in
                        Button { withAnimation(.easeInOut(duration: 0.2)) { selectedSegment = i } } label: {
                            VStack(spacing: 0) {
                                Text(segments[i])
                                    .font(.custom(selectedSegment == i ? "Inter_18pt-SemiBold" : "Inter_18pt-Regular", size: 14))
                                    .foregroundColor(selectedSegment == i ? .primaryBlue : .textSecondary)
                                    .padding(.vertical, 12)
                                Rectangle()
                                    .fill(selectedSegment == i ? Color.primaryBlue : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                }
                .background(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)

                // Content body
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        if selectedSegment == 0 {
                            legalSection(num: "1", title: "Acceptance of Terms",
                                body: "By accessing and using this application, you accept and agree to be bound by the terms and provisions of this agreement. Your continued use of the platform constitutes acceptance of any updates.")
                            legalSection(num: "2", title: "Use of the Service",
                                body: "You agree to use the service only for lawful purposes and in a way that does not infringe the rights of others. You must not misuse our services or help anyone to do so.")
                            legalSection(num: "3", title: "Medical Disclaimer",
                                body: "This application provides appointment booking and health record management services. It does not provide medical advice. Always consult a qualified healthcare professional for medical decisions.")
                            legalSection(num: "4", title: "Account Responsibility",
                                body: "You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account. Notify us immediately of any unauthorized access.")
                            legalSection(num: "5", title: "Termination",
                                body: "We reserve the right to terminate or suspend access to our service immediately if you breach these terms without prior notice or liability.")
                        } else {
                            legalSection(num: "1", title: "Information We Collect",
                                body: "We collect personal information you provide directly, such as your name, contact details, and health information necessary to provide our services. We also collect usage data automatically.")
                            legalSection(num: "2", title: "How We Use Your Data",
                                body: "Your data is used to provide and improve the service, process appointments, send reminders, and comply with legal obligations. We do not sell your personal data to third parties.")
                            legalSection(num: "3", title: "Data Security",
                                body: "We implement appropriate technical and organizational measures to safeguard your personal information against unauthorized access, alteration, disclosure, or destruction.")
                            legalSection(num: "4", title: "Sharing of Information",
                                body: "We may share your information with healthcare providers you interact with through the platform, and with service providers who assist us in operating the service under strict confidentiality agreements.")
                            legalSection(num: "5", title: "Your Rights",
                                body: "You have the right to access, correct, or delete your personal information. Contact our support team to exercise these rights. We will respond within 30 days.")
                        }
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarHidden(true)
    }

    //has the body paragraph section with title and badges
    private func legalSection(num: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.primaryBlueTint)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(num)
                            .font(.custom("Inter_18pt-Bold", size: 13))
                            .foregroundColor(.primaryBlue)
                    )
                Text(title)
                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                    .foregroundColor(.textPrimary)
            }
            Text(body)
                .font(.custom("Inter_18pt-Regular", size: 13))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
