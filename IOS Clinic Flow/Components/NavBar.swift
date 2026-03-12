import SwiftUI

struct NavBar: View {
    let title: String
    var onBack: (() -> Void)? = nil
    var trailingIcon: String? = nil
    var onTrailing: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 0) {
            // Back button
            if let onBack = onBack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                }
                .frame(width: 44)
            } else {
                Spacer().frame(width: 44)
            }

            Spacer()

            // Center screen Title
            Text(title)
                .font(.custom("Inter_18pt-SemiBold", size: 17))
                .foregroundColor(.textPrimary)

            Spacer()

            
            if let icon = trailingIcon, let action = onTrailing {
                Button {
                    action()
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                }
                .frame(width: 44)
            } else {
                Spacer().frame(width: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(hex: "EEF1F5"))
    }
}
