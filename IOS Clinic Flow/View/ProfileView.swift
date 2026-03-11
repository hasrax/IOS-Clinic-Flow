//
//  ProfileView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-11.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var router = AppRouter.shared

    private var tabBinding: Binding<TabItem> {
        Binding(
            get: { AppRouter.shared.activeTab },
            set: { tab in if tab != .profile { AppRouter.shared.pendingTab = tab } }
        )
    }

    @State private var displayName  = MockUser.current.name
    @State private var displayPhone = MockUser.current.phone

    // mock data
    @State private var allergies: [String]                        = ["shellfish", "milk", "Peanuts", "Bees", "Penicillin"]
    @State private var emergencyContacts: [(name: String, phone: String)] = [
        (name: "Nimali Sonali", phone: "+94 77 6579 234")
    ]

    // Navigation steps
    @State private var showEditProfile   = false
    @State private var showLab           = false
    @State private var showPrescriptions = false
    @State private var showCompanion     = false
    @State private var showLanguage      = false
    @State private var showPrivacy       = false
    @State private var showHelp          = false
    @State private var showTerms         = false

    // Sheet / dialog steps
    @State private var showAddAllergy    = false
    @State private var showAddContact    = false
    @State private var showLogoutAlert   = false
    @State private var newAllergyText    = ""
    @State private var newContactName    = ""
    @State private var newContactPhone   = ""

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                //NavBar
                HStack {
                    Spacer().frame(width: 44)
                    Spacer()
                    Text("Profile")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.primaryBlue)
                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Avatar/name section
                        VStack(spacing: 6) {
                            ZStack(alignment: .bottomTrailing) {
                                Image("malini_avatar")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
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
                            Text(displayName)
                                .font(.custom("Inter_18pt-Bold", size: 18))
                                .foregroundColor(.textPrimary)
                            Text(displayPhone)
                                .font(.custom("Inter_18pt-Regular", size: 13))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, 12)

                        // Stats/Allergies/Emergency Contact card
                        VStack(spacing: 16) {
                            // Stats row
                            HStack(spacing: 10) {
                                statBox(label: "Blood\nType", value: MockUser.current.bloodType)
                                statBox(label: "Age",         value: "\(MockUser.current.age)")
                                statBox(label: "Weight",      value: MockUser.current.weight)
                                statBox(label: "Height",      value: MockUser.current.height)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                            Divider().padding(.horizontal, 16)

                            // Allergies section
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Allergies")
                                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    Button { showAddAllergy = true } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.textPrimary)
                                    }
                                }
                                .padding(.horizontal, 16)

                                FlowLayout(spacing: 8) {
                                    ForEach(allergies, id: \.self) { allergy in
                                        HStack(spacing: 4) {
                                            Text(allergy)
                                                .font(.custom("Inter_18pt-Regular", size: 13))
                                                .foregroundColor(Color(hex: "E05D9D"))
                                            Button {
                                                allergies.removeAll { $0 == allergy }
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundColor(Color(hex: "E05D9D"))
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "FCE4F3"))
                                        .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }

                            Divider().padding(.horizontal, 16)

                            // Emergency Contact
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Emergency Contact")
                                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    Button { showAddContact = true } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.textPrimary)
                                    }
                                }
                                .padding(.horizontal, 16)

                                ForEach(emergencyContacts, id: \.phone) { contact in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(Color.primaryBlueTint)
                                            .frame(width: 38, height: 38)
                                            .overlay(
                                                Image(systemName: "phone.fill")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.primaryBlue)
                                            )
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(contact.phone)
                                                .font(.custom("Inter_18pt-SemiBold", size: 14))
                                                .foregroundColor(.textPrimary)
                                            Text(contact.name)
                                                .font(.custom("Inter_18pt-Regular", size: 12))
                                                .foregroundColor(.textSecondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)

                        menuSection(title: "Account") {
                            menuItem(icon: "pencil.line",
                                     iconBg: Color(hex: "E8F1FF"),
                                     iconColor: .primaryBlue,
                                     title: "Edit Profile") { showEditProfile = true }
                        }

                        menuSection(title: "Medical Records") {
                            menuItem(icon: "doc.text.fill",
                                     iconBg: Color(hex: "E8F1FF"),
                                     iconColor: Color(hex: "4B7BEC"),
                                     title: "Past Consultation") { AppRouter.shared.pendingTab = .history }
                            Divider().padding(.leading, 56)
                            menuItem(icon: "cross.vial.fill",
                                     iconBg: Color(hex: "FFF0EC"),
                                     iconColor: Color(hex: "FF6B35"),
                                     title: "Lab Reports") { showLab = true }
                            Divider().padding(.leading, 56)
                            menuItem(icon: "pills.fill",
                                     iconBg: Color(hex: "F0EDFF"),
                                     iconColor: Color(hex: "7C4DFF"),
                                     title: "Prescriptions") { showPrescriptions = true }
                        }

                        menuSection(title: "Companion Mode") {
                            menuItem(icon: "person.2.fill",
                                     iconBg: Color(hex: "E8F1FF"),
                                     iconColor: Color(hex: "4B7BEC"),
                                     title: "Manage Companions") { showCompanion = true }
                        }

                        menuSection(title: "Preferences") {
                            menuItem(icon: "globe",
                                     iconBg: Color(hex: "E8FFEE"),
                                     iconColor: Color(hex: "22C55E"),
                                     title: "Language") { showLanguage = true }
                            Divider().padding(.leading, 56)
                            menuItem(icon: "shield.fill",
                                     iconBg: Color(hex: "FFECEC"),
                                     iconColor: Color(hex: "EF4444"),
                                     title: "Privacy & Security") { showPrivacy = true }
                        }

                        menuSection(title: "Support") {
                            menuItem(icon: "questionmark.circle.fill",
                                     iconBg: Color(hex: "F5F5F5"),
                                     iconColor: Color.textSecondary,
                                     title: "Help & Support") { showHelp = true }
                            Divider().padding(.leading, 56)
                            menuItem(icon: "doc.fill",
                                     iconBg: Color(hex: "F5F5F5"),
                                     iconColor: Color.textSecondary,
                                     title: "Terms & privacy policy") { showTerms = true }
                        }

                        Button { showLogoutAlert = true } label: {
                            Text("Log Out")
                                .font(.custom("Inter_18pt-SemiBold", size: 16))
                                .foregroundColor(Color(hex: "EF4444"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "FFF0F0"))
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 100)
                    }
                }

                BottomTabBar(selectedTab: tabBinding)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)

        //Navigation Destinations
        .navigationDestination(isPresented: $showEditProfile) {
            EditProfileView(name: $displayName, phone: $displayPhone)
        }
        .navigationDestination(isPresented: $showLab)           { LabView() }
        .navigationDestination(isPresented: $showPrescriptions) { PrescriptionsView() }
        .navigationDestination(isPresented: $showCompanion)     { CompanionView() }
        .navigationDestination(isPresented: $showLanguage)      { LanguageView() }
        .navigationDestination(isPresented: $showPrivacy)       { PrivacySecurityView() }
        .navigationDestination(isPresented: $showHelp)          { HelpSupportView() }
        .navigationDestination(isPresented: $showTerms)         { TermsPrivacyView() }

        //Custom Logout popup box
        .overlay {
            if showLogoutAlert {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture { showLogoutAlert = false }
                    logoutDialog
                }
            }
        }

        // adding allergy
        .sheet(isPresented: $showAddAllergy) {
            addAllergySheet
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
        }

        //adding emergency contact
        .sheet(isPresented: $showAddContact) {
            addContactSheet
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - info Box
    private func statBox(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 11))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.custom("Inter_18pt-Bold", size: 16))
                .foregroundColor(.primaryBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(hex: "EEF3FF"))
        .cornerRadius(12)
    }

    // MARK: - Menu Section
    // that has tasks and navigations
    private func menuSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Inter_18pt-Regular", size: 13))
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 20)
            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
    }

    
