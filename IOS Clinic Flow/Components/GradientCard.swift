import SwiftUI

struct GradientCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var shadowOpacity: Double = 0.25
    @ViewBuilder let content: Content

    var body: some View {
        content
            .background(LinearGradient.primaryGradient)
            .cornerRadius(cornerRadius)
            .shadow(
                color: Color.primaryBlue.opacity(shadowOpacity),
                radius: 12, x: 0, y: 6
            )
    }
}

struct WhiteCard<Content: View>: View {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Color.white)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
