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
    
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        Color(.systemGroupedBackground)
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated steam above logo (all three identical, animated)
                SimpleAnimatedSteamTrails()
                .frame(height: 54)
                .offset(y: -30)
                
                // PNG Logo (no steam)
                Image("LogoNoSteam")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 5)
                
                // App Title
                Text("Steamed")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "4b7db0"), Color(hex: "335b8c")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.steamedBlue.opacity(0.3), radius: 2, x: 0, y: 2)

                Text("Stop Memorizing. Start Reading.")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.secondary)
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
                    gradient: Gradient(colors: [.steamedBlue, .steamedDarkBlue]),
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
