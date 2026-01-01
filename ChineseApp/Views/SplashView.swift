//
//  SplashView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-12-23.
//

import SwiftUI
import Combine

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    // Custom Light Blue Theme Color
    let steamedBlue = Color(red: 0.6, green: 0.85, blue: 0.95) // Pastel Light Blue
    let steamedDarkBlue = Color(red: 0.3, green: 0.5, blue: 0.7) // Darker blue for gradient
    
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
    var steamedGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.6, green: 0.85, blue: 0.95), Color(red: 0.3, green: 0.5, blue: 0.7)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            // Background: white or black depending on system
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated steam above logo (all three identical, animated)
                SimpleAnimatedSteamTrails()
                .frame(height: 54)
                .offset(y: -30)
                
                // PNG Logo (no steam)
                Image("LogoImageSet")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 5)
                
                // App Title
                    Text("Steamed")
                        .font(Font.custom("SF Pro Rounded", size: 42).weight(.black))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)

                    Text("Freshly Served Chinese")
                        .font(Font.custom("SF Pro Rounded", size: 20).weight(.semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
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
            // Wait for 1.7 seconds then dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                withAnimation {
                    self.showSplash = false
                }
            }
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}

// MARK: - Simple Up-and-Down Animated Steam Trails
struct SimpleAnimatedSteamTrails: View {
    var body: some View {
        HStack(spacing: 18) {
            SimpleAnimatedSteamTrail(offset: 0, delay: 0.0)
            SimpleAnimatedSteamTrail(offset: 10, delay: 0.3)
            SimpleAnimatedSteamTrail(offset: -10, delay: 0.6)
        }
        .frame(height: 54)
        .offset(y: 10)
    }
}

struct SimpleAnimatedSteamTrail: View {
    @State private var up = false
    var offset: CGFloat
    var delay: Double
    var body: some View {
        SteamWavyShape()
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.6, green: 0.85, blue: 0.95), Color(red: 0.3, green: 0.5, blue: 0.7)]),
                    startPoint: .top, endPoint: .bottom),
                style: StrokeStyle(lineWidth: 10, lineCap: .round)
            )
            .frame(width: 22, height: 54)
            .opacity(0.85)
            .offset(y: up ? offset : offset + 12)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                        up.toggle()
                    }
                }
            }
    }
}

struct SteamWavyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let points = 24
        let amplitude: CGFloat = 7
        let baseX = w / 2
        path.move(to: CGPoint(x: baseX, y: h))
        for i in 0...points {
            let y = h - CGFloat(i) * h / CGFloat(points)
            let t = CGFloat(i) / CGFloat(points)
            let wave = sin(t * 2 * .pi) * amplitude
            path.addLine(to: CGPoint(x: baseX + wave, y: y))
        }
        return path
    }
}
