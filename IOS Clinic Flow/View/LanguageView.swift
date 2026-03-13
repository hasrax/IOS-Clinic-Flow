import SwiftUI

struct LanguageView: View {
    @State private var selectedLanguage = "English" // Stores the currently selected language
    @State private var isFinished = false

    // Array of available language options
    let languages = [
        ("English", "British English"),
        ("සිංහල", "Sinhala"),
        ("தமிழ்", "Tamil"),
    ]

    var body: some View {
        if isFinished {
            LoginView()
        } else {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Illustration section
                    ZStack {
                        Circle()
                            .fill(Color(hex: "E2E6EE"))
                            .frame(width: 280, height: 280)

                        Circle()
                            .fill(Color(hex: "D0D8EA"))
                            .frame(width: 200, height: 200)

                        // Language illustration content
                        VStack(spacing: 8) {
                            Text("文A")
                                .font(.custom("Inter_18pt-Black", size: 52))
                                .foregroundColor(.primaryBlue.opacity(0.3))
                            
                            // Small greeting labels
                            HStack(spacing: 12) {
                                ForEach(["HELLO", "HOLA", "HALLO"], id: \.self) { word in
                                    Text(word)
                                        .font(.custom("Inter_18pt-Bold", size: 9))
                                        .foregroundColor(.primaryBlue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .frame(height: 320)

                    // Welcome text section
                    VStack(alignment: .center, spacing: 4) {
                        Text("WELCOME !")
                            .font(.custom("Inter_18pt-ExtraBold", size: 24))
                            .foregroundColor(.textPrimary)
                        Text("Select Your Language")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)

                    // Language selection options
                    VStack(spacing: 12) {
                        ForEach(languages, id: \.0) { lang in
                            Button {
                                selectedLanguage = lang.0
                            } label: {
                                VStack(spacing: 2) {
                                    Text(lang.0)
                                        .font(.custom("Inter_18pt-SemiBold", size: 16))
                                        .foregroundColor(.textPrimary)
                                    Text(lang.1)
                                        .font(.custom("Inter_18pt-Regular", size: 12))
                                        .foregroundColor(.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    selectedLanguage == lang.0
                                    ? Color.primaryBlue.opacity(0.08)
                                    : Color.white
                                )
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            selectedLanguage == lang.0
                                            ? Color.primaryBlue.opacity(0.3)
                                            : Color.borderLight,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 28)

                    Spacer()

                    // Continue button
                    Button {
                        isFinished = true
                    } label: {
                        Text("Continue")
                            .font(.custom("Inter_18pt-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(LinearGradient.primaryGradient)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
                }
            }
        }
    }
}


