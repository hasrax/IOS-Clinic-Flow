//
//  ChecklistView.swift
//  IOS Clinic Flow
//
//  Created by Lakindu Siriwardena on 2026-03-10.
//

import SwiftUI

// MARK: - Models
private struct ChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    var isChecked: Bool
}

private struct ChecklistSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var items: [ChecklistItem]
    var isExpanded: Bool

    var readyCount: Int { items.filter(\.isChecked).count }
    var totalCount: Int { items.count }
    //to check how many check are made in the list
    var summaryText: String { "\(readyCount) of \(totalCount) ready" }
}

// MARK: - main view design
struct ChecklistView: View {
    @ObservedObject private var router = AppRouter.shared

    private var tabBinding: Binding<TabItem> {
        Binding(
            get: { AppRouter.shared.activeTab },
            set: { tab in if tab != .checklist { AppRouter.shared.pendingTab = tab } }
        )
        //this is so that if the parameters are changed then the list also changes
    }

    @State private var sections: [ChecklistSection] = [
        ChecklistSection(
            title: "Documents To Bring",
            icon: "doc.text.fill",
            items: [
                ChecklistItem(title: "National ID / Passport", isChecked: true),
                ChecklistItem(title: "Insurance Card",         isChecked: true),
                ChecklistItem(title: "Previous Records",       isChecked: false),
                ChecklistItem(title: "Referral Letter",        isChecked: false),
                ChecklistItem(title: "Lab Reports",            isChecked: false),
                ChecklistItem(title: "X-Ray / Scan Reports",   isChecked: false),
            ],
            isExpanded: false
        ),
        ChecklistSection(
            title: "Lab Reports To Bring",
            icon: "doc.text.fill",
            items: [
                ChecklistItem(title: "Blood Test Report",      isChecked: true),
                ChecklistItem(title: "Urine Analysis",         isChecked: true),
                ChecklistItem(title: "Lipid Panel",            isChecked: false),
                ChecklistItem(title: "Thyroid Panel",          isChecked: false),
                ChecklistItem(title: "Liver Function Test",    isChecked: false),
                ChecklistItem(title: "HbA1c Report",           isChecked: false),
            ],
            isExpanded: false
        ),
        ChecklistSection(
            title: "Medications To Bring",
            icon: "doc.text.fill",
            items: [
                ChecklistItem(title: "Current Prescriptions",  isChecked: true),
                ChecklistItem(title: "Insulin / Injections",   isChecked: true),
                ChecklistItem(title: "Vitamin Supplements",    isChecked: false),
                ChecklistItem(title: "Blood Pressure Meds",    isChecked: false),
                ChecklistItem(title: "Pain Relievers",         isChecked: false),
                ChecklistItem(title: "Eye Drops / Topicals",   isChecked: false),
            ],
            isExpanded: false
        ),
    ]
//hard coded items to bring because we dont have a backend yet xxxx
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // navigqation
                HStack {
                    Spacer().frame(width: 44)
                    Spacer()
                    Text("Visit Checklist")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.primaryBlue)
                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        Spacer().frame(height: 8)

                        ForEach($sections) { $section in
                            ChecklistSectionView(section: $section)
                                .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 100)
                    }
                }

                BottomTabBar(selectedTab: tabBinding)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }
}

// MARK: - section view
private struct ChecklistSectionView: View {
    @Binding var section: ChecklistSection

    var body: some View {
        VStack(spacing: 0) {
            // Hheader is made tappable
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    section.isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primaryBlueTint)
                            .frame(width: 42, height: 42)
                        Image(systemName: section.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primaryBlue)
                    }

                    // Title + count
                    VStack(alignment: .leading, spacing: 3) {
                        Text(section.title)
                            .font(.custom("Inter_18pt-SemiBold", size: 15))
                            .foregroundColor(.textPrimary)
                        Text(section.summaryText)
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    // ch
                    Image(systemName: section.isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(section.isExpanded ? 0 : 16)
                .clipShape(
                    section.isExpanded
                    ? RoundedCorner(radius: 16, corners: [.topLeft, .topRight])
                    : RoundedCorner(radius: 16, corners: .allCorners)
                )
            }
            .buttonStyle(.plain)

            // allows the user to expand and make items small as well
            if section.isExpanded {
                VStack(spacing: 0) {
                    ForEach($section.items) { $item in
                        ChecklistItemRow(item: $item)

                        if item.id != section.items.last?.id {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight]))
            }
        }
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Item Row
private struct ChecklistItemRow: View {
    @Binding var item: ChecklistItem

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                item.isChecked.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            item.isChecked ? Color.successGreen : Color(hex: "D1D5DB"),
                            lineWidth: 1.5
                        )
                        .frame(width: 24, height: 24)
//the tappable navigation the the user can check and the animation for the checking stuff
                    if item.isChecked {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.successGreen)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // Label
                Text(item.title)
                    .font(.custom(
                        item.isChecked ? "Inter_18pt-Regular" : "Inter_18pt-Medium",
                        size: 14
                    ))
                    .foregroundColor(item.isChecked ? .textTertiary : .textPrimary)
                    .strikethrough(item.isChecked, color: .textTertiary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ChecklistView()
    }
}
