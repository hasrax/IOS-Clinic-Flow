//
//  CompanionView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-10.
//

import SwiftUI
import Combine

// MARK: - Mock Data for the companions
private let mockCareForList: [CareForPerson] = [
    CareForPerson(
        id: 1, name: "Amal Perera", relation: "Father", age: 64,
        phone: "+ xx xxx xxxx", avatar: "doctor_kamal",
        conditions: ["Diabetes", "Hypertension"],
        lastVisit: "Last Feb 23, 2025",
        upcomingAppt: nil,
        queueData: CompanionQueueData(
            position: 5, doctor: "Dr. K. Perera", room: "Room 204",
            estimatedWait: "~25 min", currentStep: "Waiting for consultation",
            steps: []
        ),
        alerts: [
            CompanionAlert(id: 1, text: "Queue position updated to #5", time: "10:15 AM", type: "queue"),
            CompanionAlert(id: 2, text: "Appointment confirmed for Feb 23", time: "Yesterday", type: "appointment"),
            CompanionAlert(id: 3, text: "Lab results ready for download", time: "Feb 22", type: "lab")
        ]
    ),
    CareForPerson(
        id: 2, name: "Malithi Perera", relation: "Sister", age: 32,
        phone: "+ xx xxx xxxx", avatar: "malini_avatar",
        conditions: [],
        lastVisit: "Last Feb 23, 2025",
        upcomingAppt: nil,
        queueData: nil,
        alerts: []
    )
]

private let mockMyCompanions: [MyCompanion] = [
    MyCompanion(
        id: 1, name: "Saman Perera", relation: "Son", avatar: "doctor_nipun",
        phone: "+ xx xxx xxxx",
        permissions: ["Book appointments", "Track queue status"],
        linkedSince: "Jan 15, 2025", status: "active"
    )
]

struct CompanionView: View {
    //build dismiss action to work back button
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: CompanionTab = .iCareFor
    @State private var showAddCompanion = false
    @State private var navigateToAlerts: CareForPerson? = nil
    @State private var navigateToQueue: CareForPerson? = nil
    @State private var showAlertsView = false
    @State private var showQueueView = false
    @State private var navTab: TabItem = .home

    //to track the active tab
    enum CompanionTab { case iCareFor, myCompanions, pending }

    var body: some View {
        //zstack layers the grey background
        NavigationStack {
            ZStack {
                Color(hex: "F0F2F5").ignoresSafeArea()
                //spacing stcks the nav bar , scrolling area and tab bar with gaps
                VStack(spacing: 0) {
                    // NavBar with plus button for add companion one
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                        Spacer()
                        Text("Companion Mode")
                            .font(.custom("Inter_18pt-Bold", size: 18))
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Button {
                            showAddCompanion = true
                        } label: {
                            //wrapped in this for rounded borders
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.borderMedium, lineWidth: 1)
                                    .frame(width: 34, height: 34)
                                Image(systemName: "plus")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color(hex: "F0F2F5"))

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                    
                            infoBanner

                            tabPills

                            switch selectedTab {
                            case .iCareFor: iCareForContent
                            case .myCompanions: myCompanionsContent
                            case .pending: pendingContent
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }

                    BottomTabBar(selectedTab: $navTab)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
            //to show alerts screen- naviagtions to other screens
            .navigationDestination(isPresented: $showAlertsView) {
                if let person = navigateToAlerts {
                    CompanionAlertsView(person: person)
                }
            }
            .navigationDestination(isPresented: $showQueueView) {
                if let person = navigateToQueue {
                    CompanionQueueView(person: person)
                }
            }
        }
        .sheet(isPresented: $showAddCompanion) {
            AddCompanionSheet(isPresented: $showAddCompanion)
        }
        .navigationBarHidden(true)
        .onAppear { if AppRouter.shared.pendingTab != nil { dismiss() } }
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
    }

    // MARK: blue banner
    private var infoBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlueTint)
                    .frame(width: 42, height: 42)
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.primaryBlue)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Care For Your Loved Ones")
                    .font(.custom("Inter_18pt-SemiBold", size: 14))
                    .foregroundColor(.primaryBlue)
                Text("Track queues, book visits and receive alerts\nfrom family members")
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

    // MARK: Tabs
    private var tabPills: some View {
        HStack(spacing: 0) {
            tabPill(title: "I Care For", tab: .iCareFor)
            tabPill(title: "My Companions", tab: .myCompanions)
            tabPillPending
        }
        .padding(4)// to not touch container
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    //this is to show the functions of tab pills
    private func tabPill(title: String, tab: CompanionTab) -> some View {
        Button { selectedTab = tab } label: {
            Text(title)
                .font(.custom("Inter_18pt-SemiBold", size: 13))
                .foregroundColor(selectedTab == tab ? .white : .textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    selectedTab == tab
                        ? AnyView(LinearGradient.primaryGradient)//active
                        : AnyView(Color.clear)//inactive
                )
                .clipShape(RoundedRectangle(cornerRadius: 9))
        }
    }

    private var tabPillPending: some View {
        Button { selectedTab = .pending } label: {
            HStack(spacing: 5) {
                Text("Pending")
                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                    .foregroundColor(selectedTab == .pending ? .white : .textSecondary)
                ZStack {
                    Circle()
                        .fill(Color.errorRed)
                        .frame(width: 18, height: 18)
                    Text("1")
                        .font(.custom("Inter_18pt-Bold", size: 10))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                selectedTab == .pending
                    ? AnyView(LinearGradient.primaryGradient)
                    : AnyView(Color.clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
    }

    // MARK: I Care For part
    private var iCareForContent: some View {
        VStack(spacing: 14) {
            ForEach(mockCareForList) { person in
                careForCard(person: person)
            }
        }
    }
    
    //card design
    private func careForCard(person: CareForPerson) -> some View {
        VStack(spacing: 0) {
            // Top section
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.primaryBlueTint)
                            .frame(width: 52, height: 52)
                        Image(person.avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(person.name)
                            .font(.custom("Inter_18pt-SemiBold", size: 15))
                            .foregroundColor(.textPrimary)
                        Text("\(person.relation) - Age \(person.age)")
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    // Status dot
                    Circle()
                        .fill(person.queueData != nil ? Color.successGreen : Color.warningAmber)
                        .frame(width: 10, height: 10)
                }

                // Condition tags
                if !person.conditions.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(person.conditions, id: \.self) { cond in
                            Text(cond)
                                .font(.custom("Inter_18pt-Medium", size: 11))
                                .foregroundColor(Color(hex: "E45C5C"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "FEECEC"))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        Spacer()
                    }
                }

                if let queue = person.queueData {
                    Button {
                        navigateToQueue = person
                        showQueueView = true
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color.successGreen)
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Live Queue - Position \(queue.position)")
                                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                                    .foregroundColor(.white)
                                Text("Waiting for consultation \(queue.estimatedWait)")
                                    .font(.custom("Inter_18pt-Regular", size: 11))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(LinearGradient.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                } else {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.warningAmber)
                            .frame(width: 8, height: 8)
                        Text("No Upcoming Appointments")
                            .font(.custom("Inter_18pt-Regular", size: 13))
                            .foregroundColor(.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(hex: "F9F9FB"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Info rows
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        Text(person.phone)
                            .font(.custom("Inter_18pt-Regular", size: 13))
                            .foregroundColor(.textSecondary)
                        Spacer()
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        Text(person.lastVisit)
                            .font(.custom("Inter_18pt-Regular", size: 13))
                            .foregroundColor(.textSecondary)
                        Spacer()
                    }
                }
            }
            .padding(16)

            Divider().padding(.horizontal, 16)

            // Action buttons
            HStack(spacing: 0) {
                companionActionBtn(icon: "phone.fill", label: "Call") {}
                companionActionBtn(icon: "location.fill", label: "Track") {
                    navigateToQueue = person
                    showQueueView = true
                }
                companionActionBtn(icon: "bell.fill", label: "Alerts") {
                    navigateToAlerts = person
                    showAlertsView = true
                }
                companionActionBtn(icon: "house.fill", label: "Book") {}
            }
            .padding(.vertical, 4)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private func companionActionBtn(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(.primaryBlue)
                Text(label)
                    .font(.custom("Inter_18pt-Medium", size: 11))
                    .foregroundColor(.primaryBlue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.primaryBlueTint)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
    }

    // MARK: My Companions Content
    private var myCompanionsContent: some View {
        VStack(spacing: 14) {
            ForEach(mockMyCompanions) { companion in
                myCompanionCard(companion: companion)
            }
            if mockMyCompanions.isEmpty {
                emptyState(icon: "person.2", message: "No companions have been linked yet")
            }
        }
    }

    private func myCompanionCard(companion: MyCompanion) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.primaryBlueTint)
                        .frame(width: 48, height: 48)
                    Image(companion.avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(companion.name)
                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                        .foregroundColor(.textPrimary)
                    Text(companion.relation)
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Text(companion.status == "active" ? "Active" : "Inactive")
                    .font(.custom("Inter_18pt-SemiBold", size: 11))
                    .foregroundColor(companion.status == "active" ? .successGreen : .textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(companion.status == "active" ? Color.successTint : Color.surfaceMuted)
                    .clipShape(Capsule())
            }
            .padding(16)

            Divider().padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 8) {
                Text("Can access:")
                    .font(.custom("Inter_18pt-Medium", size: 12))
                    .foregroundColor(.textSecondary)
                HStack(spacing: 8) {
                    ForEach(companion.permissions, id: \.self) { perm in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.successGreen)
                            Text(perm)
                                .font(.custom("Inter_18pt-Regular", size: 11))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().padding(.horizontal, 16)

            HStack {
                Button {
                } label: {
                    Text("Remove Access")
                        .font(.custom("Inter_18pt-SemiBold", size: 13))
                        .foregroundColor(.errorRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(hex: "FEF2F2"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // MARK: Pending Content
    private var pendingContent: some View {
        VStack(spacing: 14) {
            pendingInviteCard(
                name: "Ruwan Silva",
                relation: "Wants to care for you",
                phone: "+94 77 123 4567",
                linkType: "They care for me"
            )
        }
    }

    private func pendingInviteCard(name: String, relation: String, phone: String, linkType: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.warningTint)
                        .frame(width: 48, height: 48)
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.warningAmber)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                        .foregroundColor(.textPrimary)
                    Text(relation)
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                    Text(phone)
                        .font(.custom("Inter_18pt-Regular", size: 12))
                        .foregroundColor(.textTertiary)
                }
                Spacer()
                Text("Pending")
                    .font(.custom("Inter_18pt-SemiBold", size: 11))
                    .foregroundColor(.warningAmber)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.warningTint)
                    .clipShape(Capsule())
            }
            .padding(16)

            Divider().padding(.horizontal, 16)

            HStack(spacing: 12) {
                Button {
                } label: {
                    Text("Decline")
                        .font(.custom("Inter_18pt-SemiBold", size: 13))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.surfaceMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Button {
                } label: {
                    Text("Accept")
                        .font(.custom("Inter_18pt-SemiBold", size: 13))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(LinearGradient.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // MARK: Empty State
    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.textLight)
            Text(message)
                .font(.custom("Inter_18pt-Regular", size: 14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

// MARK: - Add Companion Sheet
struct AddCompanionSheet: View {
    @Binding var isPresented: Bool
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var selectedRelationship: String? = nil
    @State private var linkType: LinkType = .iCareForThem

    enum LinkType { case iCareForThem, theyCareforme }

    private let relationships = ["Father", "Mother", "Child", "Spouse", "Sibling", "Other"]
    private let permissions = ["Book appointments", "Track queue status", "Access lab results", "Manage Pharmacy"]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Companion")
                    .font(.custom("Inter_18pt-Bold", size: 20))
                    .foregroundColor(.textPrimary)
                Spacer()
                Button { isPresented = false } label: {
                    ZStack {
                        Circle()
                            .fill(Color.surfaceMuted)
                            .frame(width: 32, height: 32)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Full Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.custom("Inter_18pt-Medium", size: 14))
                            .foregroundColor(.textPrimary)
                        TextField("Enter Name", text: $fullName)
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderMedium, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Phone Number
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number")
                            .font(.custom("Inter_18pt-Medium", size: 14))
                            .foregroundColor(.textPrimary)
                        TextField("+ 94 XX XXX XXXX", text: $phoneNumber)
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .keyboardType(.phonePad)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderMedium, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Relationship
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Relationship")
                            .font(.custom("Inter_18pt-Medium", size: 14))
                            .foregroundColor(.textPrimary)
                        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(relationships, id: \.self) { rel in
                                Button {
                                    selectedRelationship = rel
                                } label: {
                                    Text(rel)
                                        .font(.custom("Inter_18pt-Medium", size: 13))
                                        .foregroundColor(selectedRelationship == rel ? .primaryBlue : .textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 11)
                                        .background(
                                            selectedRelationship == rel
                                                ? Color.primaryBlueTint
                                                : Color.white
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(
                                                    selectedRelationship == rel ? Color.primaryBlue.opacity(0.3) : Color.borderMedium,
                                                    lineWidth: 1
                                                )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    // Link Type
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Link Type")
                            .font(.custom("Inter_18pt-Medium", size: 14))
                            .foregroundColor(.textPrimary)
                        HStack(spacing: 12) {
                            linkTypeCard(
                                icon: "heart.fill",
                                title: "I care for them",
                                subtitle: "You manage their visits",
                                type: .iCareForThem
                            )
                            linkTypeCard(
                                icon: "person.2.fill",
                                title: "They care for me",
                                subtitle: "They see your status",
                                type: .theyCareforme
                            )
                        }
                    }

                    // Permissions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Permissions")
                            .font(.custom("Inter_18pt-Medium", size: 14))
                            .foregroundColor(.textPrimary)
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(permissions, id: \.self) { perm in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.textSecondary)
                                        .frame(width: 5, height: 5)
                                    Text(perm)
                                        .font(.custom("Inter_18pt-Regular", size: 14))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                    }

                    // Send Button
                    Button {
                        isPresented = false
                    } label: {
                        Text("Send companion invite")
                            .font(.custom("Inter_18pt-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(hex: "F0F2F5"))
    }

    private func linkTypeCard(icon: String, title: String, subtitle: String, type: LinkType) -> some View {
        Button { linkType = type } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(linkType == type ? .primaryBlue : .textTertiary)
                Text(title)
                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                    .foregroundColor(linkType == type ? .primaryBlue : .textPrimary)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.custom("Inter_18pt-Regular", size: 11))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 10)
            .background(linkType == type ? Color(hex: "EBF0FA") : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(linkType == type ? Color.primaryBlue.opacity(0.25) : Color.borderMedium, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

