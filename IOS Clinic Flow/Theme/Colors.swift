import SwiftUI

extension Color {
    // This the primary colr set - buttons, headers
    static let primaryBlue = Color(hex: "0B3B8F")
    static let primaryBlueDark = Color(hex: "0A2F6E")
    static let primaryBlueDarker = Color(hex: "082D6E")
    static let accentBlue = Color(hex: "3B82F6")// for links

    // Background color set - screen background, cards
    static let appBackground = Color(hex: "F5F5F7")
    static let cardBackground = Color.white
    static let surfaceMuted = Color(hex: "F3F4F6")//for inactive areas

    // This shows the status colors
    static let successGreen = Color(hex: "22C55E")
    static let warningAmber = Color(hex: "F59E0B")
    static let errorRed = Color(hex: "EF4444")
    static let purpleAccent = Color(hex: "A855F7") // these three for specialty tags
    static let cyanAccent = Color(hex: "06B6D4")
    static let indigoAccent = Color(hex: "6366F1")

    // Color set for the Texts
    static let textPrimary = Color(hex: "1A1A2E")// main headings plus body texts
    static let textSecondary = Color(hex: "6B7280")// subheaders and descriptions
    static let textTertiary = Color(hex: "9CA3AF")//helping texts
    static let textLight = Color(hex: "C4C9D1")// disabled ones

    // Border  color set
    static let borderLight = Color.black.opacity(0.04)
    static let borderMedium = Color.black.opacity(0.06)

    // Primary tint clor set
    static let primaryBlueTint = Color(hex: "0B3B8F").opacity(0.06)
    static let primaryBlueTintMedium = Color(hex: "0B3B8F").opacity(0.08)
    //these for the badges
    static let successTint = Color(hex: "22C55E").opacity(0.08)
    static let warningTint = Color(hex: "F59E0B").opacity(0.08)
    static let errorTint = Color(hex: "EF4444").opacity(0.06)
    static let purpleTint = Color(hex: "A855F7").opacity(0.08)
    static let cyanTint = Color(hex: "06B6D4").opacity(0.08)

    // Hex initializer (refered)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Gradients - Reusable buttons and card colors
extension LinearGradient {
    
    //active tabs, primary buttons
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "0B3B8F"), Color(hex: "0A2F6E")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    //cards and section headers
    static let primaryGradientDeep = LinearGradient(
        colors: [Color(hex: "0B3B8F"), Color(hex: "082D6E")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    //success, confirmation statuses
    static let successGradient = LinearGradient(
        colors: [Color(hex: "22C55E"), Color(hex: "4ADE80")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    //used to build in home view 
    static let heroGradient = LinearGradient(
        colors: [Color(hex: "061A40"), Color(hex: "1A6BCC")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
