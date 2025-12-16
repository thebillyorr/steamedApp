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
                
                // (Previously badge display; now just text + emoji celebration)
                
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
    TopicCompletionCongrats(topicCategory: "Travel")
}
