import SwiftUI

//Navigation bar indexing
enum TabItem: Int, CaseIterable {
    case home = 0
    case checklist = 1
    case history = 2
    case profile = 3
    
    var icon: String {
            switch self {
            //Adding iconc from SF to the navbar
            case .home: return "house.fill"
            case .checklist: return "list.bullet.clipboard.fill"
            case .history: return "clock.arrow.circlepath"
            case .profile: return "person.circle.fill"
            }
        }
        //Shows the string for the icon
        var label: String {
            switch self {
            case .home: return "Home"
            case .checklist: return "Checklist"
            case .history: return "History"
            case .profile: return "Profile"
            }
        }
    }

struct BottomTabBar: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        //this stack the all the tab buttons
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                Spacer(minLength: 0)
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                } label: {
                    if selectedTab == tab {
                        // Active stage
                        HStack(spacing: 7) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14, weight: .bold))
                            Text(tab.label)
                                .font(.custom("Inter_18pt-SemiBold", size: 13))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 11)
                        .background(
                            Capsule()
                                .fill(LinearGradient.primaryGradient)
                        )
                        .shadow(color: Color(hex: "1A6BCC").opacity(0.38), radius: 10, x: 0, y: 4)
                    } else {
                        // this is the inactive stage
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(Color(hex: "BBBFC8"))
                            .frame(width: 44, height: 44)
                    }
                }
                .buttonStyle(.plain)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 36)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.11), radius: 22, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomTabBar(selectedTab: .constant(.home))
    }
    .background(Color(hex: "EEF1F5"))
}

