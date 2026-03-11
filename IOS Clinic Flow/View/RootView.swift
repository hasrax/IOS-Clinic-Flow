//
//  RootView.swift
//  IOS Clinic Flow
//
//  Created by Vihanga Madushamini on 2026-03-11.
//


import SwiftUI
internal import Combine

// Root screen shown after user login.
// It manages tab switching and keeps each tab alive in the background
// so navigation state is preserved when moving between tabs.

struct RootView: View {
    var isFirstUser: Bool = false   // Checks whether this is the first-time user flow
    @StateObject private var router = AppRouter.shared
    @State private var selectedTab: TabItem = .home

    var body: some View {
        ZStack {
            // Home tab — has its own NavigationStack internally
            HomeView(isReturningUser: !isFirstUser)
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)

            // History tab
            NavigationStack { HistoryView() }
                .opacity(selectedTab == .history ? 1 : 0)
                .allowsHitTesting(selectedTab == .history)

            // Checklist tab
            NavigationStack { ChecklistView() }
                .opacity(selectedTab == .checklist ? 1 : 0)
                .allowsHitTesting(selectedTab == .checklist)

            // Profile tab
            NavigationStack { ProfileView() }
                .opacity(selectedTab == .profile ? 1 : 0)
                .allowsHitTesting(selectedTab == .profile)
        }
        .ignoresSafeArea()
        .onChange(of: selectedTab) { _, tab in
            router.activeTab = tab  // Updates the router whenever the selected tab changes
        }
        .onReceive(router.$pendingTab.compactMap { $0 }) { tab in
            selectedTab = tab
            router.activeTab = tab
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router.pendingTab = nil
            }
        }
    }
}
