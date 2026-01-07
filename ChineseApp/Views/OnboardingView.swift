//
//  OnboardingView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2026-01-06.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack {
                // Tab View for Slides
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        image: "book.fill",
                        title: "Stop Memorizing",
                        description: "Ditch the flashcards. Learn Chinese naturally by reading interesting stories tailored to your level.",
                        color: .steamedDarkBlue,
                        pageIndex: 0
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        image: "character.book.closed.fill",
                        title: "Instant Dictionary",
                        description: "Tap any word you don't know for an instant definition, pinyin, and tone usage.",
                        color: .steamedBlue,
                        pageIndex: 1
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        image: "flame.fill",
                        title: "Track Your Growth",
                        description: "Watch your mastery grow as you encounter words in different contexts. Keep your streak alive!",
                        color: Color(hex: "FF6B6B"), // Accent color for flame
                        pageIndex: 2
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom Controls
                VStack(spacing: 20) {
                    // Custom Page Indicators
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(currentPage == index ? Color.steamedDarkBlue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Action Button
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            // Finish Onboarding
                            withAnimation {
                                isOnboardingCompleted = true
                            }
                        }
                    }) {
                        Text(currentPage == 2 ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.steamedDarkBlue)
                            .cornerRadius(25)
                            .shadow(color: Color.steamedDarkBlue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 40)
                    
                    if currentPage < 2 {
                        Button("Skip") {
                            withAnimation {
                                isOnboardingCompleted = true
                            }
                        }
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    } else {
                        // Spacer to keep layout consistent when "Skip" is hidden
                        Text(" ")
                            .font(.subheadline)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage: View {
    let image: String
    let title: String
    let description: String
    let color: Color
    let pageIndex: Int
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(color)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .rotationEffect(pageIndex == 1 && isAnimating ? .degrees(10) : .degrees(0))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isOnboardingCompleted: .constant(false))
}
