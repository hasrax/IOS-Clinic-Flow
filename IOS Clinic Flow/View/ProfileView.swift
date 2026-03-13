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

    @State private var allergies: [String]                        = ["shellfish", "milk", "Peanuts", "Bees", "Penicillin"]
    @State private var emergencyContacts: [(name: String, phone: String)] = [
        (name: "Nimali Sonali", phone: "+94 77 6579 234")
    ]

    init() {
        let isNew = AppRouter.shared.isNewUser
        _displayName = State(initialValue: isNew ? "" : MockUser.current.name)
        _displayPhone = State(initialValue: isNew ? "+94 \(AppRouter.shared.loggedInPhone)" : MockUser.current.phone)
        _allergies = State(initialValue: isNew ? [] : ["shellfish", "milk", "Peanuts", "Bees", "Penicillin"])
        _emergencyContacts = State(initialValue: isNew ? [] : [(name: "Nimali Sonali", phone: "+94 77 6579 234")])
    }

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
                NavBar(title: "Profile", titleColor: .primaryBlue)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Avatar/name section
                        VStack(spacing: 6) {
                            ZStack(alignment: .bottomTrailing) {
                                if router.isNewUser {
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
                                statBox(label: "Blood\nType", value: router.isNewUser ? "—" : MockUser.current.bloodType)
                                statBox(label: "Age",         value: router.isNewUser ? "—" : "\(MockUser.current.age)")
                                statBox(label: "Weight",      value: router.isNewUser ? "—" : MockUser.current.weight)
                                statBox(label: "Height",      value: router.isNewUser ? "—" : MockUser.current.height)
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
                                            .foregroundColor(Color(hex: "1B3A6B"))
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
                                            .foregroundColor(Color(hex: "1B3A6B"))
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

    // MARK: - Logout box
    private var logoutDialog: some View {
        let firstName = displayName.components(separatedBy: " ").first ?? displayName
        return VStack(spacing: 0) {
            // Title
            Text("Logout")
                .font(.custom("Inter_18pt-Bold", size: 20))
                .foregroundColor(Color.primaryBlue)
                .padding(.top, 24)
                .padding(.bottom, 16)

            Divider()

            // Message
            Text("Are you sure you want to logout of \(firstName)'s account ?")
                .font(.custom("Inter_18pt-Regular", size: 14))
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)

            // Buttons
            HStack(spacing: 12) {
                // Logout — bordered
                Button {
                    showLogoutAlert = false
                    AppRouter.shared.isLoggedIn = false
                } label: {
                    Text("Logout")
                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                        .foregroundColor(Color.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryBlue, lineWidth: 1.5)
                        )
                }
                // Cancel — filled
                Button { showLogoutAlert = false } label: {
                    Text("Cancel")
                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.primaryBlue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 8)
        .padding(.horizontal, 40)
    }

    // MARK: - Menu Items deisgn
    private func menuItem(icon: String, iconBg: Color, iconColor: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 9)
                    .fill(iconBg)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 15))
                            .foregroundColor(iconColor)
                    )
                Text(title)
                    .font(.custom("Inter_18pt-Medium", size: 15))
                    .foregroundColor(.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Allergy Sheet design
    private var addAllergySheet: some View {
        VStack(spacing: 20) {
            Text("Add Allergy")
                .font(.custom("Inter_18pt-Bold", size: 17))
                .foregroundColor(.textPrimary)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text("Allergy name")
                    .font(.custom("Inter_18pt-Medium", size: 13))
                    .foregroundColor(.textSecondary)
                TextField("e.g. Aspirin, Latex, Dust…", text: $newAllergyText)
                    .font(.custom("Inter_18pt-Regular", size: 14))
                    .padding(14)
                    .background(Color.surfaceMuted)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            Button {
                let t = newAllergyText.trimmingCharacters(in: .whitespaces)
                if !t.isEmpty { allergies.append(t) }
                newAllergyText = ""
                showAddAllergy = false
            } label: {
                Text("Add Allergy")
                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient.primaryGradient)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Emergency Contact Sheet
    private var addContactSheet: some View {
        VStack(spacing: 16) {
            Text("Add Emergency Contact")
                .font(.custom("Inter_18pt-Bold", size: 17))
                .foregroundColor(.textPrimary)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text("Full Name")
                    .font(.custom("Inter_18pt-Medium", size: 13))
                    .foregroundColor(.textSecondary)
                TextField("e.g. Nimali Sonali", text: $newContactName)
                    .font(.custom("Inter_18pt-Regular", size: 14))
                    .padding(14)
                    .background(Color.surfaceMuted)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 6) {
                Text("Phone Number")
                    .font(.custom("Inter_18pt-Medium", size: 13))
                    .foregroundColor(.textSecondary)
                TextField("+94 77 000 0000", text: $newContactPhone)
                    .keyboardType(.phonePad)
                    .font(.custom("Inter_18pt-Regular", size: 14))
                    .padding(14)
                    .background(Color.surfaceMuted)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            Button {
                let n = newContactName.trimmingCharacters(in: .whitespaces)
                let p = newContactPhone.trimmingCharacters(in: .whitespaces)
                if !n.isEmpty && !p.isEmpty {
                    emergencyContacts.append((name: n, phone: p))
                }
                newContactName = ""
                newContactPhone = ""
                showAddContact = false
            } label: {
                Text("Add Contact")
                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient.primaryGradient)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

// MARK: - FlowLayout
// apples layput protocol which is that can custom
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.height }.max() ?? 0 }
            .reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowH = row.map { $0.height }.max() ?? 0
            for item in row {
                item.view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.size.width + spacing
            }
            y += rowH + spacing
        }
    }

    private struct ItemLayout {
        let view: LayoutSubview; let size: CGSize
        var width: CGFloat { size.width }; var height: CGFloat { size.height }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[ItemLayout]] {
        let maxW = proposal.width ?? 0
        var rows: [[ItemLayout]] = []; var row: [ItemLayout] = []; var rowW: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(ProposedViewSize(width: maxW, height: nil))
            if rowW + s.width > maxW && !row.isEmpty {
                rows.append(row); row = [ItemLayout(view: v, size: s)]; rowW = s.width + spacing
            } else {
                row.append(ItemLayout(view: v, size: s)); rowW += s.width + spacing
            }
        }
        if !row.isEmpty { rows.append(row) }
        return rows
    }
}

