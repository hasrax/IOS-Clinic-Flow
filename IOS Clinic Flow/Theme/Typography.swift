import SwiftUI

//Used Inter font, and this extension helps to set static properties

// Font weight guide used here:
//   Regular < Medium < SemiBold < Bold < ExtraBold < Black
extension Font {
    // Display - bold text, splash screens, onboading screens
    static let displayLarge = Font.custom("Inter_18pt-Black", size: 32)
    static let displayMedium = Font.custom("Inter_18pt-ExtraBold", size: 28)
    static let displaySmall = Font.custom("Inter_18pt-Bold", size: 24)

    // Heading - titles in screens, card headers, small section titles
    static let headingLarge = Font.custom("Inter_18pt-Bold", size: 20)
    static let headingMedium = Font.custom("Inter_18pt-Bold", size: 18)
    static let headingSmall = Font.custom("Inter_18pt-SemiBold", size: 17)

    // Body - general
    static let bodyLarge = Font.custom("Inter_18pt-SemiBold", size: 16)
    static let bodyMedium = Font.custom("Inter_18pt-Medium", size: 15)
    static let bodySmall = Font.custom("Inter_18pt-Regular", size: 14)

    // Label - tags, captions, badges
    static let labelLarge = Font.custom("Inter_18pt-SemiBold", size: 13)
    static let labelMedium = Font.custom("Inter_18pt-Medium", size: 12)
    static let labelSmall = Font.custom("Inter_18pt-SemiBold", size: 11)
    static let labelXSmall = Font.custom("Inter_18pt-Bold", size: 10)

    // To show amounts and tokens when we displaying monetary values, counts (basically numbers)
    static let amountLarge = Font.custom("Inter_18pt-Black", size: 30)
    static let amountMedium = Font.custom("Inter_18pt-ExtraBold", size: 22)
    static let amountSmall = Font.custom("Inter_18pt-Bold", size: 18)
}
