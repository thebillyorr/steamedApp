//
//  SplashView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-12-23.
//

import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var steamOffset: CGFloat = 0
    @State private var steamOpacity: Double = 0.0
    
    // Custom Light Blue Theme Color
    let steamedBlue = Color(red: 0.6, green: 0.85, blue: 0.95) // Pastel Light Blue
    let steamedDarkBlue = Color(red: 0.3, green: 0.5, blue: 0.7) // Darker blue for gradient
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [steamedBlue, steamedDarkBlue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Minimalist Bun Logo
                ZStack {
                    // Steam Animation
                    HStack(spacing: 15) {
                        SteamParticle(delay: 0.0)
                        SteamParticle(delay: 0.4)
                        SteamParticle(delay: 0.2)
                    }
                    .offset(y: -60)
                    
                    // The Custom Drawn Bun
                    BaoLogo()
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                        .frame(width: 120, height: 100)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                
                // App Title
                Text("Steamed")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                Text("Freshly Served Chinese")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                // Animate content in
                withAnimation(.easeOut(duration: 1.0)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
            }
        }
        .onAppear {
            // Wait for 2.5 seconds then dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.showSplash = false
                }
            }
        }
    }
}

// Custom Shape matching the "Dim Sum" icon
struct BaoLogo: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Start at left shoulder
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.35))
        
        // Big rounded bottom body
        path.addCurve(
            to: CGPoint(x: width * 0.8, y: height * 0.35),
            control1: CGPoint(x: width * 0.05, y: height * 0.95),
            control2: CGPoint(x: width * 0.95, y: height * 0.95)
        )
        
        // Top wavy part (The pinch/folds)
        // Right bump
        path.addQuadCurve(
            to: CGPoint(x: width * 0.65, y: height * 0.25),
            control: CGPoint(x: width * 0.82, y: height * 0.15)
        )
        // Middle bump (knot)
        path.addQuadCurve(
            to: CGPoint(x: width * 0.35, y: height * 0.25),
            control: CGPoint(x: width * 0.5, y: height * 0.05)
        )
        // Left bump
        path.addQuadCurve(
            to: CGPoint(x: width * 0.2, y: height * 0.35),
            control: CGPoint(x: width * 0.18, y: height * 0.15)
        )
        
        // Internal pleat lines (drawn as sub-paths)
        // Left pleat
        path.move(to: CGPoint(x: width * 0.35, y: height * 0.4))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.30, y: height * 0.65),
            control: CGPoint(x: width * 0.38, y: height * 0.55)
        )
        
        // Right pleat
        path.move(to: CGPoint(x: width * 0.65, y: height * 0.4))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.70, y: height * 0.65),
            control: CGPoint(x: width * 0.62, y: height * 0.55)
        )
        
        return path
    }
}

// Helper view for rising steam
struct SteamParticle: View {
    let delay: Double
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        Capsule()
            .fill(Color.white.opacity(0.6))
            .frame(width: 6, height: 20)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    offset = -30
                    opacity = 0
                }
                
                // Initial state reset for loop
                opacity = 0.8
            }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
