//
//  EditProfileView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-11.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var name:  String
    @Binding var phone: String

    @State private var draftName   = ""
    @State private var draftEmail  = ""
    @State private var draftPhone  = ""
    @State private var draftNIC    = ""
    @State private var draftGender = ""
    @State private var showSuccess = false

    private let genders = ["Female", "Male", "Other", "Prefer not to say"]

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
                    Text("Edit Profile")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.primaryBlue)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Avatar
                        VStack(spacing: 8) {
                            ZStack(alignment: .bottomTrailing) {
                                if AppRouter.shared.isNewUser {
                                    Circle()
                                        .fill(Color(hex: "D8DCE6"))
                                        .frame(width: 90, height: 90)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 36))
                                                .foregroundColor(Color(hex: "8A93A6"))
                                        )
                                } else {
                                    Image("malini_avatar")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 90)
                                        .clipShape(Circle())
                                }
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.textSecondary)
                                    )
                                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                            }
                            Text(name)
                                .font(.custom("Inter_18pt-Bold", size: 17))
                                .foregroundColor(.textPrimary)
                            Text(phone)
                                .font(.custom("Inter_18pt-Regular", size: 13))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, 12)

                        //Form fields
                        VStack(spacing: 0) {
                            formField(label: "Full Name",     text: $draftName,   placeholder: "Vihanga Madushamini")
                            Divider().padding(.horizontal, 16)
                            formField(label: "Email Address", text: $draftEmail,  placeholder: "email@example.com",   keyboard: .emailAddress)
                            Divider().padding(.horizontal, 16)
                            formField(label: "Phone Number",  text: $draftPhone,  placeholder: "+94 77 000 0000",     keyboard: .phonePad)
                            Divider().padding(.horizontal, 16)
                            formField(label: "NIC",           text: $draftNIC,    placeholder: "200176599876")
                            Divider().padding(.horizontal, 16)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Gender")
                                    .font(.custom("Inter_18pt-Regular", size: 13))
                                    .foregroundColor(.textSecondary)
                                Menu {
                                    ForEach(genders, id: \.self) { g in
                                        Button(g) { draftGender = g }
                                    }
                                } label: {
                                    HStack {
                                        Text(draftGender.isEmpty ? "Select" : draftGender)
                                            .font(.custom("Inter_18pt-Regular", size: 15))
                                            .foregroundColor(draftGender.isEmpty ? .textSecondary : .textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)

                        // Update button
                        Button {
                            let n = draftName.trimmingCharacters(in: .whitespaces)
                            let p = draftPhone.trimmingCharacters(in: .whitespaces)
                            if !n.isEmpty { name  = n }
                            if !p.isEmpty { phone = p }
                            withAnimation { showSuccess = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { dismiss() }
                        } label: {
                            Text("Update")
                                .font(.custom("Inter_18pt-Bold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.primaryBlueDark)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 40)
                    }
                }
            }

            // Success
            if showSuccess {
                VStack {
                    Spacer()
                    Text("Profile updated!")
                        .font(.custom("Inter_18pt-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.successGreen)
                        .cornerRadius(24)
                        .padding(.bottom, 50)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            draftName  = name
            draftPhone = phone
            if !AppRouter.shared.isNewUser {
                draftEmail  = "vihangamadushamini@gmail.com"
                draftNIC    = "200176599876"
                draftGender = "Female"
            }
        }
    }

    private func formField(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 13))
                .foregroundColor(.textSecondary)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(.custom("Inter_18pt-Regular", size: 15))
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
