//
//  HelpSupportView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-11.
//

import SwiftUI

// MARK: - FAQItem design
private struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    var isExpanded: Bool = false
}

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var faqItems: [FAQItem] = [
        FAQItem(question: "How do I book an appointment?",
                answer: "Tap the 'Book Appointment' button on the home screen, search for a doctor or specialty, select a date and time slot, then confirm your booking."),
        FAQItem(question: "How can I view my lab reports?",
                answer: "Go to Profile → Lab Reports, or tap the Lab icon from the home screen quick-access grid. Your results will appear once uploaded by the hospital."),
        FAQItem(question: "How do I add a companion?",
                answer: "Go to Profile → Manage Companions and tap the '+' button. Fill in the companion's details and link their patient ID if available."),
        FAQItem(question: "Can I cancel an appointment?",
                answer: "Yes — open the appointment from History or your Home queue card and tap 'Cancel Appointment'. Cancellations more than 2 hours before the slot are free of charge."),
        FAQItem(question: "How do I track my queue position?",
                answer: "Once you've checked in, your queue position updates automatically on the Home screen. You'll also receive a push notification when you're 3rd in line."),
        FAQItem(question: "How do I change the app language?",
                answer: "Go to Profile → Preferences → Language and select your preferred language from the list."),
    ]

    @State private var subject   = ""
    @State private var message   = ""
    @State private var sentToast = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // NavBar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    Spacer()
                    Text("Help & Support")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.primaryBlue)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // emergency or quick contact
                        HStack(spacing: 12) {
                            contactButton(icon: "phone.fill",    label: "Call Us",   color: Color(hex: "22C55E"))
                            contactButton(icon: "envelope.fill", label: "Email",     color: .primaryBlue)
                            contactButton(icon: "message.fill",  label: "Live Chat", color: Color(hex: "7C4DFF"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 6)

                        // FAQ
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequently Asked Questions")
                                .font(.custom("Inter_18pt-SemiBold", size: 15))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                ForEach($faqItems) { $item in
                                    VStack(alignment: .leading, spacing: 0) {
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.22)) {
                                                item.isExpanded.toggle()
                                            }
                                        } label: {
                                            HStack {
                                                Text(item.question)
                                                    .font(.custom("Inter_18pt-Medium", size: 14))
                                                    .foregroundColor(.textPrimary)
                                                    .multilineTextAlignment(.leading)
                                                Spacer()
                                                Image(systemName: item.isExpanded ? "chevron.up" : "chevron.down")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.textSecondary)
                                            }
                                            .padding(16)
                                        }
                                        .buttonStyle(.plain)

                                        if item.isExpanded {
                                            Text(item.answer)
                                                .font(.custom("Inter_18pt-Regular", size: 13))
                                                .foregroundColor(.textSecondary)
                                                .padding(.horizontal, 16)
                                                .padding(.bottom, 14)
                                                .transition(.opacity.combined(with: .move(edge: .top)))
                                        }

                                        if item.id != faqItems.last?.id {
                                            Divider().padding(.horizontal, 16)
                                        }
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                            .padding(.horizontal, 20)
                        }

                        // to send a message
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Send a Message")
                                .font(.custom("Inter_18pt-SemiBold", size: 15))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)

                            VStack(spacing: 12) {
                                TextField("Subject", text: $subject)
                                    .font(.custom("Inter_18pt-Regular", size: 14))
                                    .padding(14)
                                    .background(Color.surfaceMuted)
                                    .cornerRadius(12)

                                ZStack(alignment: .topLeading) {
                                    if message.isEmpty {
                                        Text("Describe your issue…")
                                            .font(.custom("Inter_18pt-Regular", size: 14))
                                            .foregroundColor(.textTertiary)
                                            .padding(14)
                                    }
                                    TextEditor(text: $message)
                                        .font(.custom("Inter_18pt-Regular", size: 14))
                                        .frame(height: 100)
                                        .padding(10)
                                        .background(Color.surfaceMuted)
                                        .cornerRadius(12)
                                        .opacity(message.isEmpty ? 0.5 : 1)
                                }

                                Button {
                                    subject = ""; message = ""
                                    withAnimation { sentToast = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation { sentToast = false }
                                    }
                                } label: {
                                    Text("Send Message")
                                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(LinearGradient.primaryGradient)
                                        .cornerRadius(14)
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                            .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 40)
                    }
                }
            }

            // success message
            if sentToast {
                VStack {
                    Spacer()
                    Text("Message sent!")
                        .font(.custom("Inter_18pt-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24).padding(.vertical, 12)
                        .background(Color.successGreen)
                        .cornerRadius(24)
                        .padding(.bottom, 50)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
    }

    //a bar for the quick contacts
    private func contactButton(icon: String, label: String, color: Color) -> some View {
        Button { } label: {
            VStack(spacing: 6) {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(color)
                    )
                Text(label)
                    .font(.custom("Inter_18pt-Medium", size: 12))
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
