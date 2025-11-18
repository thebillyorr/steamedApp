//
//  TopicCompletionCongrats.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-15.
//

import SwiftUI

struct TopicCompletionCongrats: View {
    let topicCategory: String
    var onComplete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCelebration = false
    @State private var scaleBadge = false
    @State private var showText = false
    
    private var badge: TopicBadge? {
        TopicBadgeManager.shared.getBadge(for: topicCategory)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.25),
                    Color(red: 0.05, green: 0.1, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating particles effect
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: CGFloat.random(in: 4...12), height: CGFloat.random(in: 4...12))
                    .offset(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -200...200))
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true),
                        value: showCelebration
                    )
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Celebration emoji with bounce
                Text("🎉")
                    .font(.system(size: 100))
                    .scaleEffect(showCelebration ? 1.2 : 0.8)
                    .opacity(showCelebration ? 1 : 0)
                    .animation(
                        Animation.spring(response: 0.6, dampingFraction: 0.6)
                            .delay(0.2),
                        value: showCelebration
                    )
                
                VStack(spacing: 16) {
                    Text("Topic Mastered!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("You've completed all \(topicCategory) decks")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(showText ? 1 : 0)
                .animation(
                    Animation.easeInOut(duration: 0.6).delay(0.4),
                    value: showText
                )
                
                Spacer()
                
                // Badge Display with scale animation
                if let badge = badge {
                    VStack(spacing: 24) {
                        // Badge coin with 3D effect
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: badge.badgeColor).opacity(0.4),
                                            Color(hex: badge.badgeColor).opacity(0.1)
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 120
                                    )
                                )
                                .frame(width: 240, height: 240)
                            
                            // Badge coin with shadow
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: badge.badgeColor),
                                            Color(hex: badge.badgeColor).opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 200, height: 200)
                                .shadow(color: Color(hex: badge.badgeColor), radius: 20, x: 0, y: 10)
                            
                            // Inner shine effect
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.5),
                                            Color.black.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 200, height: 200)
                            
                            // Roman numeral with bold text
                            Text(badge.romanNumeral)
                                .font(.system(size: 96, weight: .black))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(scaleBadge ? 1 : 0.3)
                        .opacity(scaleBadge ? 1 : 0)
                        .animation(
                            Animation.spring(response: 0.7, dampingFraction: 0.5)
                                .delay(0.6),
                            value: scaleBadge
                        )
                        
                        VStack(spacing: 8) {
                            Text("🏆 \(topicCategory) \(badge.romanNumeral) Master")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Your badge has been added to your profile")
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .opacity(showText ? 1 : 0)
                        .animation(
                            Animation.easeInOut(duration: 0.6).delay(0.8),
                            value: showText
                        )
                    }
                }
                
                Spacer()
                
                // Continue button with slide-up animation
                Button(action: {
                    onComplete?()  // Call the callback first
                    dismiss()      // Then dismiss this screen
                }) {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.blue.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .offset(y: showText ? 0 : 50)
                .opacity(showText ? 1 : 0)
                .animation(
                    Animation.easeInOut(duration: 0.6).delay(1.0),
                    value: showText
                )
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            showCelebration = true
            showText = true
            scaleBadge = true
        }
        .interactiveDismissDisabled(false)
    }
}

#Preview {
    TopicCompletionCongrats(topicCategory: "Beginner")
}
