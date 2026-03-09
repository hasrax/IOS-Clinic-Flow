import SwiftUI

struct SplashView: View {
    // State variables used to control splash screen animation effects
    @State private var isActive      = false
    @State private var logoOpacity   = 0.0
    @State private var logoScale     = 0.75
    @State private var ring1_Scale    = 0.6
    @State private var ring1_Opacity  = 0.0
    @State private var ring2_Scale    = 0.6
    @State private var ring2_Opacity  = 0.0
    @State private var pulseScale    = 1.0
    
    var body: some View {
        if isActive {
              OnboardingView()
                }
        else {
            ZStack {
                    // Background gradient
                    LinearGradient(
                      colors: [Color(hex: "EEF1F5"), Color.white],
                      startPoint: .top, endPoint: .bottom
                    )
                      .ignoresSafeArea()

                    VStack(spacing: 36) {
                      Spacer()

                    // Logo with pulse rings
                    ZStack {
                        // Outer pulse ring
                        Circle()
                            .stroke(Color.primaryBlue.opacity(ring1_Opacity * 0.25), lineWidth: 1.5)
                            .frame(width: 200, height: 200)
                            .scaleEffect(ring1_Scale)

                        // Inner pulse ring
                        Circle()
                            .stroke(Color.primaryBlue.opacity(ring2_Opacity * 0.45), lineWidth: 2)
                            .frame(width: 160, height: 160)
                            .scaleEffect(ring2_Scale)

                        // Logo
                            Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130)
                            .opacity(logoOpacity)
                            .scaleEffect(logoScale)
                            .scaleEffect(pulseScale)
                    }

                    Spacer()
                    }
                }
            
            .onAppear {
                            // Logo fade-in + scale up
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                                logoOpacity = 1.0
                                logoScale   = 1.0
                            }

                            // Ring 1 expands outward
                            withAnimation(.easeOut(duration: 0.9).delay(0.4)) {
                                ring1_Scale   = 1.0
                                ring1_Opacity = 1.0
                            }
                            withAnimation(.easeIn(duration: 0.5).delay(1.0)) {
                                ring1_Opacity = 0.0 // Outer ring fades away
                            }

                            // Ring 2 expands with slight delay
                            withAnimation(.easeOut(duration: 0.9).delay(0.6)) {
                                ring2_Scale   = 1.0
                                ring2_Opacity = 1.0
                            }
                            withAnimation(.easeIn(duration: 0.5).delay(1.1)) {
                                ring2_Opacity = 0.0 // Inner ring fades away
                            }

                            // Gentle pulse on logo
                            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.8)) {
                                pulseScale = 1.055
                            }

                            // Navigate away
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                                // After 2.6 seconds, move to next screen
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    isActive = true
                                }
                            }
                        }
        }
        
    }
}
