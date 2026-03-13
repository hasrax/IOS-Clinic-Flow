import SwiftUI

enum NavBarTrailingStyle {
    case plain
    case boxed
}

struct NavBar: View {
    let title: String
    var subtitle: String? = nil
    var onBack: (() -> Void)? = nil
    var trailingIcon: String? = nil
    var trailingStyle: NavBarTrailingStyle = .plain
    var onTrailing: (() -> Void)? = nil
    var backColor: Color = .primaryBlue
    var titleColor: Color = .textPrimary
    var subtitleColor: Color = .textSecondary
    var backgroundColor: Color = .appBackground

    var body: some View {
        HStack(spacing: 0) {
            // Back button
            if let onBack = onBack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(backColor)
                }
                .frame(width: 44)
            } else {
                Spacer().frame(width: 44)
            }

            Spacer()

            // Center screen Title
            if let subtitle = subtitle {
                VStack(spacing: 1) {
                    Text(title)
                        .font(.custom("Inter_18pt-SemiBold", size: 17))
                        .foregroundColor(titleColor)
                    Text(subtitle)
                        .font(.custom("Inter_18pt-Regular", size: 11))
                        .foregroundColor(subtitleColor)
                }
            } else {
                Text(title)
                    .font(.custom("Inter_18pt-SemiBold", size: 17))
                    .foregroundColor(titleColor)
            }

            Spacer()

            
            if let icon = trailingIcon, let action = onTrailing {
                Button {
                    action()
                } label: {
                    Group {
                        if trailingStyle == .boxed {
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(backColor)
                                .frame(width: 30, height: 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.borderLight, lineWidth: 1.5)
                                )
                        } else {
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(backColor)
                        }
                    }
                }
                .frame(width: 44)
            } else {
                Spacer().frame(width: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(backgroundColor)
    }
}
