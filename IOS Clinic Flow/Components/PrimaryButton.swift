import SwiftUI

//Main full button that has main actions
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            if !isDisabled { action() }
        } label: {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.custom("Inter_18pt-Bold", size: 16))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                isDisabled
                ? LinearGradient(colors: [Color(hex: "B0B8C8")], startPoint: .leading, endPoint: .trailing)
                : LinearGradient.primaryGradient
            )
            .cornerRadius(16)
        }
        .disabled(isDisabled)
    }
}

//This is the secondary button with a blur borderv - less prominent
struct OutlineButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                }
                Text(title)
                    .font(.custom("Inter_18pt-Bold", size: 16))
                    .foregroundColor(.primaryBlue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(Color.clear)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primaryBlue.opacity(0.25), lineWidth: 1.5)
            )
        }
    }
}
