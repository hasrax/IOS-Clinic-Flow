//
//  PrivacySecurityView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-11.
//

import SwiftUI

struct PrivacySecurityView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var biometricOn    = true
    @State private var twoFactorOn    = false
    @State private var dataSharingOn  = true
    @State private var analyticsOn    = true
    @State private var marketingOn    = false
    @State private var showDeleteAlert = false

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
                    Text("Privacy & Security")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.primaryBlue)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Security
                        sectionCard(title: "Security") {
                            toggleRow(icon: "faceid",   iconColor: Color(hex: "7C4DFF"), title: "Face ID / Biometric Login",  value: $biometricOn)
                            Divider().padding(.leading, 54)
                            toggleRow(icon: "lock.shield.fill", iconColor: .primaryBlue, title: "Two-Factor Authentication",  value: $twoFactorOn)
                            Divider().padding(.leading, 54)
                            Button { } label: {
                                HStack(spacing: 14) {
                                    RoundedRectangle(cornerRadius: 9).fill(Color(hex: "FFF0EC"))
                                        .frame(width: 36, height: 36)
                                        .overlay(Image(systemName: "key.fill").font(.system(size: 14)).foregroundColor(Color(hex: "FF6B35")))
                                    Text("Change Password")
                                        .font(.custom("Inter_18pt-Medium", size: 15))
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.textTertiary)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 13)
                            }
                            .buttonStyle(.plain)
                        }

                        // Privacy
                        sectionCard(title: "Privacy") {
                            toggleRow(icon: "waveform.path.ecg",  iconColor: Color(hex: "22C55E"), title: "Share health data with doctors", value: $dataSharingOn)
                            Divider().padding(.leading, 54)
                            toggleRow(icon: "chart.bar.fill",      iconColor: Color(hex: "4B7BEC"), title: "Analytics & improvement",       value: $analyticsOn)
                            Divider().padding(.leading, 54)
                            toggleRow(icon: "megaphone.fill",      iconColor: Color(hex: "F59E0B"), title: "Marketing emails",               value: $marketingOn)
                        }

                        // Active Sessions
                        sectionCard(title: "Active Sessions") {
                            HStack(spacing: 14) {
                                RoundedRectangle(cornerRadius: 9).fill(Color(hex: "E8F1FF"))
                                    .frame(width: 36, height: 36)
                                    .overlay(Image(systemName: "iphone").font(.system(size: 16)).foregroundColor(.primaryBlue))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("iPhone (This device)")
                                        .font(.custom("Inter_18pt-Medium", size: 14))
                                        .foregroundColor(.textPrimary)
                                    Text("Last active: just now")
                                        .font(.custom("Inter_18pt-Regular", size: 12))
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                                Circle().fill(Color.successGreen).frame(width: 8, height: 8)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 13)
                        }

                        //Danger Zone
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Danger Zone")
                                .font(.custom("Inter_18pt-Regular", size: 13))
                                .foregroundColor(.errorRed)
                                .padding(.horizontal, 20)
                            Button { showDeleteAlert = true } label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 15))
                                        .foregroundColor(.errorRed)
                                    Text("Delete Account")
                                        .font(.custom("Inter_18pt-Medium", size: 15))
                                        .foregroundColor(.errorRed)
                                    Spacer()
                                }
                                .padding(.horizontal, 16).padding(.vertical, 14)
                                .background(Color(hex: "FFF0F0"))
                                .cornerRadius(14)
                                .padding(.horizontal, 20)
                            }
                        }

                        Spacer().frame(height: 40)
                    }
                    .padding(.top, 6)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
    }

   
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Inter_18pt-Regular", size: 13))
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 20)
            VStack(spacing: 0) { content() }
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 20)
        }
    }

    
    private func toggleRow(icon: String, iconColor: Color, title: String, value: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 9).fill(iconColor.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: icon).font(.system(size: 15)).foregroundColor(iconColor))
            Text(title)
                .font(.custom("Inter_18pt-Medium", size: 15))
                .foregroundColor(.textPrimary)
            Spacer()
            Toggle("", isOn: value).labelsHidden()
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }
}
