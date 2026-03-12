//
//  NotificationsView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-11.
//

import SwiftUI

// MARK: - Notification Item data model
struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationItemType
    let title: String
    let body: String
    let time: String
    var isRead: Bool
}

enum NotificationItemType {
    case queue
    case reminder
    case cancelled
    case schedule
    
    var icon: String {
        switch self {
        case .queue: return "car.front.waves.up.fill"
        case .reminder: return "bell.badge.fill"
        case .cancelled: return "xmark"
        case .schedule: return "calendar.badge.clock"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .queue: return .primaryBlue
        case .reminder: return Color(hex: "F59E0B")
        case .cancelled: return .textTertiary
        case .schedule: return .primaryBlue
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .queue: return .primaryBlueTint
        case .reminder: return Color(hex: "FEF3C7")
        case .cancelled: return Color.surfaceMuted
        case .schedule: return .primaryBlueTint
        }
    }
}

//body data
struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navTab: TabItem = .home
   
    @State private var todayNotifications: [NotificationItem] = [
        NotificationItem(
            type: .queue,
            title: "Your turn is approaching!",
            body: "You are 3rd in queue for Dr. Samantha Perera. Please stay nearby.",
            time: "28 min",
            isRead: false
        ),
        NotificationItem(
            type: .reminder,
            title: "Reminder",
            body: "You have an appointment tomorrow at 9:30 AM with Dr. Perera.",
            time: "58 min",
            isRead: false
        ),
        NotificationItem(
            type: .cancelled,
            title: "Appointment Canceled",
            body: "You appointment on 03 Sep at 20.30 PM has been canceled. Back again",
            time: "28 min",
            isRead: false
        )
    ]

    @State private var yesterdayNotifications: [NotificationItem] = [
        NotificationItem(
            type: .schedule,
            title: "Doctor Schedule",
            body: "Dr. Ashali Perera (Neurologists) has updated their availability",
            time: "",
            isRead: true
        ),
        NotificationItem(
            type: .reminder,
            title: "Reminder",
            body: "You have an appointment tomorrow at 9:30 AM with Dr. Ashali.",
            time: "",
            isRead: true
        ),
        NotificationItem(
            type: .cancelled,
            title: "Appointment Canceled",
            body: "You appointment on 07 Aug at 14.30 PM has been canceled. Back again",
            time: "",
            isRead: true
        )
    ]
    
//body layout
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Today Section
                        NotificationSection(
                            title: "Today",
                            notifications: $todayNotifications,
                            onMarkAllRead: {
                                for i in todayNotifications.indices {
                                    todayNotifications[i].isRead = true
                                }
                            }
                        )
                        
                        // Yesterday Section
                        NotificationSection(
                            title: "Yesterday",
                            notifications: $yesterdayNotifications,
                            onMarkAllRead: {
                                for i in yesterdayNotifications.indices {
                                    yesterdayNotifications[i].isRead = true
                                }
                            }
                        )
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 8)
                }
                
                // Tab Bar
                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Notifications")
                    .font(.custom("Inter_18pt-Bold", size: 18))
                    .foregroundColor(.textPrimary)
            }
        }
    }
}

// MARK: - Notification Section design
struct NotificationSection: View {
    let title: String
    @Binding var notifications: [NotificationItem]
    let onMarkAllRead: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Section Header
            HStack {
                Text(title)
                    .font(.custom("Inter_18pt-SemiBold", size: 14))
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Button(action: onMarkAllRead) {
                    Text("Mark All Read")
                        .font(.custom("Inter_18pt-Medium", size: 13))
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(.horizontal, 20)
            
            // Notification Cards
            VStack(spacing: 10) {
                ForEach(notifications) { notification in
                    NotificationCard(notification: notification)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Notification Card design
struct NotificationCard: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.type.backgroundColor)
                    .frame(width: 44, height: 44)
                Image(systemName: notification.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(notification.type.iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.custom("Inter_18pt-SemiBold", size: 14))
                        .foregroundColor(notification.type == .cancelled ? .textSecondary : .primaryBlue)
                    
                    Spacer()
                    
                    if !notification.time.isEmpty {
                        Text(notification.time)
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textTertiary)
                    }
                }
                
                Text(notification.body)
                    .font(.custom("Inter_18pt-Regular", size: 13))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    notification.isRead ? Color.clear : Color.primaryBlue.opacity(0.3),
                    lineWidth: notification.isRead ? 0 : 1
                )
        )
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
