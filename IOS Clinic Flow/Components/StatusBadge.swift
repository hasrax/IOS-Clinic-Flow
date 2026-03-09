import SwiftUI

//
enum BadgeType {
    case success, warning, error, info, purple

    //the text and dot colour for the badge
    var color: Color {
        switch self {
        case .success: return Color.successGreen
        case .warning: return Color.warningAmber
        case .error: return Color.errorRed
        case .info: return Color.primaryBlue
        case .purple: return Color.purpleAccent
        }
    }

    //soft background tint
    var background: Color {
        switch self {
        case .success: return Color.successGreen.opacity(0.1)
        case .warning: return Color.warningAmber.opacity(0.1)
        case .error: return Color.errorRed.opacity(0.1)
        case .info: return Color.primaryBlue.opacity(0.08)
        case .purple: return Color.purpleAccent.opacity(0.08)
        }
    }
}

    //colored label
struct StatusBadge: View {
    let text: String
    let type: BadgeType
    var showDot: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if showDot {
                Circle()
                    .fill(type.color)
                    .frame(width: 5, height: 5)
            }
            Text(text)
                .font(.custom("Inter_18pt-SemiBold", size: 11))
                .foregroundColor(type.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(type.background)
        .cornerRadius(6)
    }
}
